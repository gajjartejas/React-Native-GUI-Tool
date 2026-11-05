import Foundation

enum BuildToolPolicy {
    static func operations(project: ProjectInfo, extraSchemes: [String] = []) throws -> [ToolOperation] {
        let root = URL(fileURLWithPath: project.path)
        let ios = root.appendingPathComponent("ios")
        let files = (try? FileManager.default.contentsOfDirectory(at: ios, includingPropertiesForKeys: nil)) ?? []
        let containers = files.filter { ["xcworkspace", "xcodeproj"].contains($0.pathExtension) }.sorted { $0.pathExtension == $1.pathExtension ? $0.path < $1.path : $0.pathExtension == "xcworkspace" }
        var schemes = Set(extraSchemes)
        for container in containers {
            schemes.insert(container.deletingPathExtension().lastPathComponent)
            var folders = [container.appendingPathComponent("xcshareddata/xcschemes")]
            let users = (try? FileManager.default.contentsOfDirectory(at: container.appendingPathComponent("xcuserdata"), includingPropertiesForKeys: nil)) ?? []
            folders += users.map { $0.appendingPathComponent("xcschemes") }
            for folder in folders {
                for file in (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? [] where file.pathExtension == "xcscheme" { schemes.insert(file.deletingPathExtension().lastPathComponent) }
            }
        }
        let reveal = ToolField(id: "reveal", label: "Open output folder after success", kind: .toggle)
        let flavor = ToolField(id: "flavor", label: "Flavor (optional)")
        let container = ToolField(id: "container", label: "Xcode workspace / project", kind: .choice(containers.map(\.path)))
        let scheme = ToolField(id: "scheme", label: "Scheme", kind: .choice(schemes.sorted()))
        let configuration = ToolField(id: "configuration", label: "Configuration", kind: .choice(["Debug", "Release"]))
        return [
            .init(id: "android-debug", title: "Android Debug APK", fields: [flavor, reveal]),
            .init(id: "android-release", title: "Android Release APK", fields: [flavor, reveal]),
            .init(id: "android-bundle", title: "Android Release App Bundle", fields: [flavor, reveal]),
            .init(id: "android-custom", title: "Android custom flavor / build type", fields: [flavor, .init(id: "type", label: "Build type", initial: "Debug"), .init(id: "format", label: "Output format", kind: .choice(["APK", "AAB"])), reveal]),
            .init(id: "ios-schemes", title: "List iOS schemes", fields: [container]),
            .init(id: "ios-simulator", title: "iOS simulator build", fields: [container, scheme, configuration, .init(id: "output", label: "Derived data directory", initial: project.path + "/build/iOSDebug"), reveal]),
            .init(id: "ios-archive", title: "iOS Release archive", fields: [container, scheme, .init(id: "output", label: "Archive (.xcarchive)", kind: .saveFile, initial: project.path + "/build/Archive.xcarchive"), reveal]),
            .init(id: "ios-export", title: "Export archive to IPA", fields: [.init(id: "archive", label: "Archive (.xcarchive)", kind: .openFile, initial: project.path + "/build/Archive.xcarchive"), .init(id: "plist", label: "Export options plist", kind: .openFile), .init(id: "output", label: "IPA output directory", initial: project.path + "/build/ipa"), reveal])
        ]
    }
    static func schemeNames(_ output: String) -> [String] {
        guard let start = output.firstIndex(of: "{"), let end = output.lastIndex(of: "}"), start <= end,
              let data = String(output[start...end]).data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
        return ((json["workspace"] ?? json["project"]) as? [String: Any])?["schemes"] as? [String] ?? []
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo) throws -> ToolPlan {
        let root = URL(fileURLWithPath: project.path)
        var directory = root.appendingPathComponent("ios").path
        let executable: String
        let args: [String]
        var output: String?
        if operation.hasPrefix("android-") {
            directory = root.appendingPathComponent("android").path
            executable = directory + "/gradlew"
            let flavor = (values["flavor"] ?? "").trimmingCharacters(in: .whitespaces)
            let type = operation == "android-debug" ? "Debug" : operation == "android-custom" ? try ToolInput.required(values, "type") : "Release"
            guard (flavor.isEmpty || flavor.range(of: #"^[A-Za-z][A-Za-z0-9_]*$"#, options: .regularExpression) != nil), type.range(of: #"^[A-Za-z][A-Za-z0-9_]*$"#, options: .regularExpression) != nil else { throw ToolInputError(message: "Use letters, digits and underscores for flavor/build type.") }
            let bundle = operation == "android-bundle" || values["format"] == "AAB"
            args = [(bundle ? "bundle" : "assemble") + flavor.prefix(1).uppercased() + flavor.dropFirst() + type.prefix(1).uppercased() + type.dropFirst()]
            output = directory + "/app/build/outputs/" + (bundle ? "bundle" : "apk")
        } else {
            executable = "/usr/bin/xcodebuild"
            if operation == "ios-export" {
                let path = try ToolInput.required(values, "output")
                guard path.hasPrefix("/") else { throw ToolInputError(message: "Use an absolute output directory.") }
                args = ["-exportArchive", "-archivePath", try ToolInput.file(values, "archive", extensions: ["xcarchive"]), "-exportOptionsPlist", try ToolInput.file(values, "plist", extensions: ["plist"]), "-exportPath", path]
                output = path
            } else {
                let container = try ToolInput.file(values, "container", extensions: ["xcworkspace", "xcodeproj"])
                let prefix = [container.hasSuffix(".xcworkspace") ? "-workspace" : "-project", container]
                if operation == "ios-schemes" { args = prefix + ["-list", "-json"] }
                else {
                    let scheme = try ToolInput.required(values, "scheme")
                    let path = try ToolInput.required(values, "output")
                    guard path.hasPrefix("/") else { throw ToolInputError(message: "Use an absolute output path.") }
                    if operation == "ios-simulator" {
                        args = prefix + ["-scheme", scheme, "-configuration", values["configuration"] ?? "Debug", "-sdk", "iphonesimulator", "-destination", "generic/platform=iOS Simulator", "-derivedDataPath", path, "CODE_SIGNING_ALLOWED=NO", "build"]
                        output = path + "/Build/Products"
                    } else if operation == "ios-archive" {
                        guard path.hasSuffix(".xcarchive") else { throw ToolInputError(message: "Archive output must end in .xcarchive.") }
                        args = prefix + ["-scheme", scheme, "-configuration", "Release", "-destination", "generic/platform=iOS", "-archivePath", path, "archive"]
                        output = URL(fileURLWithPath: path).deletingLastPathComponent().path
                    } else { throw ToolInputError(message: "Select a build operation.") }
                }
            }
        }
        return .init(commands: [.init(executable: executable, arguments: args, directory: directory)], outputDirectory: values["reveal"] == "true" ? output : nil)
    }
}
