import Cocoa

final class AdbVC: ToolCommandVC {
    private var devices: [AdbDevice] = []
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] {
        let devices = devices; return { _ in AdbToolPolicy.operations(devices: devices) }
    }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan {
        let devices = devices; return { try AdbToolPolicy.plan(operation: $0, values: $1, project: $2, devices: devices) }
    }
    override var readyStatus: String { "Refresh devices before running device actions. Offline and unauthorized devices cannot be selected." }
    override func didComplete(operation: String, result: ToolRunResult) {
        if operation == "devices" && result.exitCode == 0 && !result.cancelled {
            devices = AdbToolPolicy.devices(result.output)
            showRows(headers: ["Serial", "Model", "Status"], rows: devices.map { [$0.serial, $0.model, $0.state] })
            reloadOperations()
        }
    }
}
