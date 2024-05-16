//
//  MainProjectListWC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 02/05/24.
//

import Cocoa

class MainProjectListWC: NSWindowController, NSWindowDelegate {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = "RnGuiTools"
        window?.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.hide(self)
        return false
    }
}
