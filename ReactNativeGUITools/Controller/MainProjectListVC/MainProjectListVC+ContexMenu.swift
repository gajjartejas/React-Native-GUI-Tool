//
//  MainProjectListVC+ContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 24/04/24.
//

import Cocoa

extension MainProjectListVC: ProjectListMenuDelegate {
    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int) {
        let projectInfo = ProjectInfoCollection.shared.projectInfos[row]
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }
        let allControllers = NSWindowController.getAllControllers()
        if let foundController = NSWindowController.getAllControllers().compactMap({ $0 as? ToolsOutlineWC }).first(where: { $0.fromRow == row }) {
            foundController.window?.makeKeyAndOrderFront(self)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateController(withIdentifier: "ToolsOutlineWC") as? ToolsOutlineWC else { return }
            controller.fromRow = row
            controller.projectInfo = projectInfo
            if let mainWindow = allControllers.first?.window {
                controller.location = mainWindow.frame
            }
            //controller.showWindow(nil)
            controller.window?.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int) {
        if let view = projectListTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
            if let v = view as? ProjectListCellView {
                v.projectNameLable.becomeFirstResponder()
            }
        }
    }

    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int) {
        ProjectInfoCollection.shared.remove(at: row)
        let indexSets = IndexSet(integer: row)
        projectListTableView.removeRows(at: indexSets, withAnimation: .slideDown)
    }

    func projectListMenuNeedsUpdate(_ menu: NSMenu) {
        projectListMenu.refreshMenu(menu)
    }
}
