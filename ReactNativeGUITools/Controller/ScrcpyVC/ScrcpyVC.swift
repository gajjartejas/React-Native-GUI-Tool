import Cocoa

final class ScrcpyVC: ToolCommandVC {
    private var devices: [AdbDevice] = []
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] {
        let devices = devices; return { _ in ScrcpyToolPolicy.operations(devices: devices) }
    }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan {
        let devices = devices; return { try ScrcpyToolPolicy.plan(operation: $0, values: $1, project: $2, devices: devices) }
    }
    override func selectOperation(_ id: String) {
        super.selectOperation(id)
        panel.runButton.title = id == "start" ? "Start Mirroring" : "Run"
        panel.cancelButton.title = id == "start" ? "Stop Mirroring" : "Cancel"
    }
    override func didComplete(operation: String, result: ToolRunResult) {
        if operation == "devices" && result.exitCode == 0 && !result.cancelled {
            devices = AdbToolPolicy.devices(result.output)
            showRows(headers: ["Serial", "Model", "Status"], rows: devices.map { [$0.serial, $0.model, $0.state] })
            reloadOperations()
        }
    }
}
