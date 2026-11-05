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
