//
//  ToolsOutlineWC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 02/05/24.
//

import Cocoa

class ToolsOutlineWC: NSWindowController {
    var projectInfo: ProjectInfo? {
        didSet {
            window?.title = projectInfo?.name ?? "-"
        }
    }

    var location: NSRect? {
        didSet {
            if let origin = location?.origin {
                self.window?.setFrameOrigin(origin)
            }
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
