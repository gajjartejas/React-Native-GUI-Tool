import Foundation

enum BundletoolPolicy {
    static func operations(project: ProjectInfo) -> [ToolOperation] {
        let jar = ToolField(id: "jar", label: "bundletool.jar (optional)", kind: .openFile)
        return [
            .init(id: "version", title: "Check bundletool installation / version", fields: [jar]),
            .init(id: "build", title: "Build APKS from AAB", fields: [jar,
                .init(id: "bundle", label: "Input AAB", kind: .openFile),
                .init(id: "output", label: "New APKS output", kind: .saveFile, initial: project.path + "/build.apks"),
                .init(id: "mode", label: "APK set mode", kind: .choice(["Default", "Universal"])),
                .init(id: "keystore", label: "Keystore (blank = debug)", kind: .openFile),
                .init(id: "alias", label: "Key alias"),
                .init(id: "storepass", label: "Store password", kind: .password),
                .init(id: "keypass", label: "Key password (blank = store)", kind: .password)
            ]),
            .init(id: "install", title: "Install APKS on connected device", fields: [jar, .init(id: "apks", label: "APKS archive", kind: .openFile), .init(id: "serial", label: "Device serial (optional)")]),
            .init(id: "extract", title: "Extract universal APK (requires Universal APKS)", fields: [.init(id: "apks", label: "Universal APKS archive", kind: .openFile), .init(id: "directory", label: "Output directory", initial: project.path + "/universal-apk")])
        ]
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo) throws -> ToolPlan {
        if operation == "extract" {
            let archive = try ToolInput.file(values, "apks", extensions: ["apks"])
            let directory = try ToolInput.required(values, "directory")
            guard directory.hasPrefix("/") else { throw ToolInputError(message: "Use an absolute output directory.") }
            return .init(commands: [.init(executable: "/usr/bin/unzip", arguments: ["-n", archive, "universal.apk", "-d", directory], directory: project.path, newFiles: [URL(fileURLWithPath: directory).appendingPathComponent("universal.apk").path])])
        }
        let jar = (values["jar"] ?? "").trimmingCharacters(in: .whitespaces)
        let executable = jar.isEmpty ? "bundletool" : "java"
        var args = jar.isEmpty ? [] : ["-jar", try ToolInput.file(values, "jar", extensions: ["jar"])]
        var secrets: [Int: ToolSecret] = [:]
        var newFiles: [String] = []
        switch operation {
        case "version": args += ["version"]
        case "build":
            let output = try ToolInput.file(values, "output", extensions: ["apks"])
            args += ["build-apks", "--bundle=" + (try ToolInput.file(values, "bundle", extensions: ["aab"])), "--output=" + output]
            newFiles = [output]
            let mode = values["mode"] ?? "Default"
            guard ["Default", "Universal"].contains(mode) else { throw ToolInputError(message: "Choose Default or Universal APKS mode.") }
            if mode == "Universal" { args.append("--mode=universal") }
            if !(values["keystore"] ?? "").isEmpty {
                let storepass = try KeytoolPolicy.secret(values, "storepass")
                let keypass = (values["keypass"] ?? "").isEmpty ? storepass : try KeytoolPolicy.secret(values, "keypass")
                args += ["--ks=" + (try ToolInput.file(values, "keystore", extensions: ["jks", "keystore", "p12", "pfx", "pkcs12"])), "--ks-key-alias=" + (try ToolInput.required(values, "alias"))]
                secrets[args.count] = .init(prefix: "--ks-pass=file:", value: storepass); args.append("--ks-pass=file:<protected>")
                secrets[args.count] = .init(prefix: "--key-pass=file:", value: keypass); args.append("--key-pass=file:<protected>")
            }
        case "install":
            args += ["install-apks", "--apks=" + (try ToolInput.file(values, "apks", extensions: ["apks"]))]
            if let serial = values["serial"], !serial.isEmpty {
                guard !serial.contains("\0"), !serial.contains("\n") else { throw ToolInputError(message: "Enter a device serial without line breaks.") }
                args.append("--device-id=" + serial)
            }
        default: throw ToolInputError(message: "Choose a bundletool operation.")
        }
        return .init(commands: [.init(executable: executable, arguments: args, directory: project.path, secretFiles: secrets, newFiles: newFiles)])
    }
}
