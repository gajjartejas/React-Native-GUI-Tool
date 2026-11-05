import Cocoa

final class NpmVC: ToolCommandVC {
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] { { try PackageToolPolicy.operations(path: $0.path) } }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan { PackageToolPolicy.plan }
    override func didComplete(operation: String, result: ToolRunResult) {
        if result.exitCode == 0 && !result.cancelled && ["add", "remove", "install", "audit-fix"].contains(operation) { reloadOperations() }
    }
}
