//
//  MainProjectListWC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 02/05/24.
//

import Cocoa

class MainProjectListWC: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = "RnGuiTools"
        window?.delegate = self
        track()
    }

    deinit {
        self.remove()
    }
}

extension MainProjectListWC: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // NSApplication.shared.hide(self)
        window?.orderOut(nil)
        return false
    }
}
