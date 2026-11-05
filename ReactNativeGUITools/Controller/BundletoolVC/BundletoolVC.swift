import Cocoa

final class BundletoolVC: ToolCommandVC {
    override var operationProvider: (ProjectInfo) throws -> [ToolOperation] { { BundletoolPolicy.operations(project: $0) } }
    override var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan { BundletoolPolicy.plan }
    override var readyStatus: String { "Use installed bundletool or select its JAR. Build Universal APKS before extracting universal.apk." }
}
