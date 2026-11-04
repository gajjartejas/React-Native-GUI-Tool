//
//  ToolsOutlineWC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 02/05/24.
//

import Cocoa

class ToolsOutlineWC: NSWindowController {
    var fromRow: Int?
    var projectInfo: ProjectInfo? {
        didSet {
            window?.title = projectInfo?.name ?? "-"
            if let splitVC = window?.contentViewController as? NSSplitViewController,
               splitVC.children.indices.contains(1),
               let projectTabVC = splitVC.children[1] as? ProjectTabViewController {
                projectTabVC.projectInfo = projectInfo
            }
        }
    }

    var location: NSRect? {
        didSet {
            if let location = location {
                self.centerWindow(relativeTo: location)
            }
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        track()
    }

    deinit {
        self.remove()
    }
}

extension ToolsOutlineWC: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
