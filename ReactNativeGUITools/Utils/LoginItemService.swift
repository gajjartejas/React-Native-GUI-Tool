import Foundation
import ServiceManagement

final class LoginItemService: LoginItemManaging {
    var state: LoginItemState {
        switch SMAppService.mainApp.status {
        case .notRegistered: return .disabled
        case .enabled: return .enabled
        case .requiresApproval: return .approvalRequired
        case .notFound: return .unavailable
        @unknown default: return .unavailable
        }
    }
    func setEnabled(_ enabled: Bool) throws {
        if enabled { try SMAppService.mainApp.register() }
        else { try SMAppService.mainApp.unregister() }
    }
    static func openSettings() { SMAppService.openSystemSettingsLoginItems() }
}
