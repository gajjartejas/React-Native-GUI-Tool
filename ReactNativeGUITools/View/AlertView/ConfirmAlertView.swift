//
//  ConfirmAlertView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 09/06/24.
//

import Cocoa

class ConfirmAlertView {
    var alert: NSAlert

    init(message: String, informativeText: String, confirmButtonTitle: String, cancelButtonTitle: String, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        alert = NSAlert()
        alert.addButton(withTitle: confirmButtonTitle)
        alert.addButton(withTitle: cancelButtonTitle)
        alert.messageText = message
        alert.informativeText = informativeText

        let response = alert.runModal()
        NSApp.activate(ignoringOtherApps: true)

        if response == .alertFirstButtonReturn {
            confirmAction()
        } else if response == .alertSecondButtonReturn {
            cancelAction()
        }
    }
}
