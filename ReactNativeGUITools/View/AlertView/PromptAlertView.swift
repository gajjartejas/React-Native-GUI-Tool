//
//  PromptAlertView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

class PromptAlertView {
    var alert: NSAlert
    var textField: NSTextField
    typealias promptResponseClosure = (_ strResponse: String, _ bResponse: Bool) -> Void

    init(inputValue: String, message: String, informativeText: String) {
        alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = message
        alert.informativeText = informativeText

        textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.stringValue = inputValue
        alert.accessoryView = textField
    }

    func displayAlert() -> (String, Bool) {
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        textField.becomeFirstResponder()
        
        let userResponse = (response == NSApplication.ModalResponse.alertFirstButtonReturn)
        return (textField.stringValue, userResponse)
    }
}
