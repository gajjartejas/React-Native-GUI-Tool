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
            if let splitVC = window?.contentViewController as? NSSplitViewController,
               splitVC.children.indices.contains(1),
               let projectTabVC = splitVC.children[1] as? ProjectTabViewController {
                projectTabVC.projectInfo = projectInfo
            }
        }
    }

    /// A row is a transient projection; a window belongs to a stable project ID.
    @discardableResult
    static func show(project: ProjectInfo, selectingTab tab: Int? = nil) -> ToolsOutlineWC? {
        let controllers = NSWindowController.getAllControllers()
        let controller: ToolsOutlineWC
        if let existing = controllers.compactMap({ $0 as? ToolsOutlineWC }).first(where: { $0.projectInfo?.id == project.id }) {
            controller = existing
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let created = storyboard.instantiateController(withIdentifier: "ToolsOutlineWC") as? ToolsOutlineWC else { return nil }
            if let frame = controllers.first?.window?.frame { created.location = frame }
            controller = created
        }
        controller.projectInfo = project
        controller.window?.makeKeyAndOrderFront(nil)
        if let tab = tab { controller.selectTab(at: tab) }
        NSApp.activate(ignoringOtherApps: true)
        return controller
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

    func selectTab(at index: Int) {
        if let splitVC = window?.contentViewController as? NSSplitViewController {
            if let toolsOutlineVC = splitVC.children.first as? ToolsOutlineVC {
                toolsOutlineVC.selectNode(withIndex: index)
            }
            if splitVC.children.indices.contains(1),
               let projectTabVC = splitVC.children[1] as? ProjectTabViewController {
                projectTabVC.selectedTabViewItemIndex = index
            }
        }
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
