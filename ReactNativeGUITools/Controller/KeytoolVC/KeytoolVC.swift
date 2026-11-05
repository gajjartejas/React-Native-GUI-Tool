import Cocoa

final class KeytoolVC: ToolCommandVC {
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] { { KeytoolPolicy.operations(project: $0) } }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan { KeytoolPolicy.plan }
    override func didComplete(operation: String, result: ToolRunResult) {
        if operation == "fingerprints" && result.exitCode == 0 && !result.cancelled {
            do { appendConsole("\n" + CertificateFingerprints.describe(try KeytoolPolicy.certificateData(result.output)) + "\n") }
            catch { panel.status.stringValue = error.localizedDescription }
        }
    }
}
