import Cocoa

final class GenerateBuildVC: ToolCommandVC {
    private var schemes: [String] = []
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] {
        let schemes = schemes; return { try BuildToolPolicy.operations(project: $0, extraSchemes: schemes) }
    }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan { BuildToolPolicy.plan }
    override func projectDidChange() { schemes = [] }
    override func didComplete(operation: String, result: ToolRunResult) {
        if operation == "ios-schemes" && result.exitCode == 0 && !result.cancelled { schemes = BuildToolPolicy.schemeNames(result.output); reloadOperations() }
    }
}
