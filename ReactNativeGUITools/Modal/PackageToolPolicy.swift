import Foundation

enum PackageToolPolicy {
    static func operations(path: String) throws -> [ToolOperation] {
        let metadata = try ProjectMetadata.read(path: path)
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path).appendingPathComponent("package.json"))) as? [String: Any]
        let scripts = (json?["scripts"] as? [String: String] ?? [:]).keys.sorted()
        let packages = Array(Set(metadata.dependencies.map(\.name))).sorted()
        return [
            .init(id: "install", title: "Install dependencies", fields: [.init(id: "ci", label: "Clean install (npm ci)", kind: .toggle), .init(id: "legacy", label: "Legacy peer dependencies", kind: .toggle)]),
            .init(id: "add", title: "Add package", fields: [.init(id: "package", label: "Package / version"), .init(id: "dev", label: "Save as dev dependency", kind: .toggle)]),
            .init(id: "remove", title: "Uninstall package", fields: [.init(id: "package", label: "Installed package", kind: .choice(packages))]),
            .init(id: "outdated", title: "Outdated packages"), .init(id: "audit", title: "Security audit"), .init(id: "audit-fix", title: "Apply audit fixes"),
            .init(id: "cache-clean", title: "Clean npm cache (force)"), .init(id: "cache-verify", title: "Verify npm cache"),
            .init(id: "run", title: "Run package script", fields: [.init(id: "script", label: "Script", kind: .choice(scripts)), .init(id: "arguments", label: "Arguments (JSON array)", initial: "[]")])
        ]
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo) throws -> ToolPlan {
        let args: [String]
        switch operation {
        case "install": args = [values["ci"] == "true" ? "ci" : "install"] + (values["legacy"] == "true" ? ["--legacy-peer-deps"] : [])
        case "add": args = ["install", try ToolInput.package(values)] + (values["dev"] == "true" ? ["--save-dev"] : [])
        case "remove": args = ["uninstall", try ToolInput.package(values)]
        case "outdated", "audit": args = [operation]
        case "audit-fix": args = ["audit", "fix"]
        case "cache-clean": args = ["cache", "clean", "--force"]
        case "cache-verify": args = ["cache", "verify"]
        case "run": args = ["run", try ToolInput.required(values, "script"), "--"] + (try ToolInput.arguments(values["arguments"]))
        default: throw ToolInputError(message: "Select a supported npm operation.")
        }
        return .init(commands: [.init(executable: "npm", arguments: args, directory: project.path)])
    }
}

extension PackageToolPolicy {
    static func yarnMajor(_ output: String) -> Int? {
        for line in output.components(separatedBy: .newlines) {
            let value = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = value.split(separator: ".")
            if parts.count >= 2, let major = Int(parts[0]), Int(parts[1]) != nil { return major }
        }
        return nil
    }
    static func yarnOperations(path: String) throws -> [ToolOperation] {
        let npm = try operations(path: path)
        let packages = npm.first { $0.id == "remove" }!.fields
        let scripts = npm.first { $0.id == "run" }!.fields
        return [
            .init(id: "version", title: "Check Yarn installation / version"),
            .init(id: "install", title: "Install dependencies", fields: [.init(id: "frozen", label: "Freeze / immutable lockfile", kind: .toggle)]),
            .init(id: "add", title: "Add package", fields: [.init(id: "package", label: "Package / version"), .init(id: "dev", label: "Dev dependency (-D)", kind: .toggle)]),
            .init(id: "upgrade", title: "Upgrade dependency", fields: [.init(id: "package", label: "Package / version")]),
            .init(id: "remove", title: "Remove dependency", fields: packages),
            .init(id: "why", title: "Why is a dependency installed?", fields: packages),
            .init(id: "cache", title: "Clean Yarn cache"),
            .init(id: "run", title: "Run package script", fields: scripts)
        ]
    }
    static func yarnPlan(operation: String, values: [String: String], project: ProjectInfo, major: Int?) throws -> ToolPlan {
        let args: [String]
        switch operation {
        case "version": args = ["--version"]
        case "install":
            guard let major = major else { throw ToolInputError(message: "Check Yarn version before installing dependencies.") }
            args = ["install"] + (values["frozen"] == "true" ? [major == 1 ? "--frozen-lockfile" : "--immutable"] : [])
        case "add": args = ["add", try ToolInput.package(values)] + (values["dev"] == "true" ? ["-D"] : [])
        case "upgrade":
            guard let major = major else { throw ToolInputError(message: "Check Yarn version before upgrading dependencies.") }
            args = [major == 1 ? "upgrade" : "up", try ToolInput.package(values)]
        case "remove", "why": args = [operation, try ToolInput.package(values)]
        case "cache": args = ["cache", "clean"]
        case "run": args = ["run", try ToolInput.required(values, "script")] + (try ToolInput.arguments(values["arguments"]))
        default: throw ToolInputError(message: "Select a supported Yarn operation.")
        }
        return .init(commands: [.init(executable: "yarn", arguments: args, directory: project.path, environment: operation == "version" ? ["COREPACK_ENABLE_NETWORK":"0"] : [:])])
    }
}
