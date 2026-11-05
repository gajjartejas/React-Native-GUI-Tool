import Cocoa

final class YarnVC: ToolCommandVC {
    private var major: Int?
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] { { try PackageToolPolicy.yarnOperations(path: $0.path) } }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan {
        let major = major
        return { try PackageToolPolicy.yarnPlan(operation: $0, values: $1, project: $2, major: major) }
    }
    override var readyStatus: String { major.map { "Yarn \($0) (\($0 == 1 ? "Classic" : "Modern")). Ready." } ?? "Check Yarn installation/version before install or upgrade." }
    override func projectDidChange() { major = nil }
    override func didComplete(operation: String, result: ToolRunResult) {
        if operation == "version" {
            major = result.exitCode == 0 && !result.cancelled ? PackageToolPolicy.yarnMajor(result.output) : nil
            reloadOperations()
        } else if result.exitCode == 0 && !result.cancelled && ["add", "remove", "install", "upgrade"].contains(operation) { reloadOperations() }
    }
}
