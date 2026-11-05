//
//  MainProjectListVC+ContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 24/04/24.
//

import Cocoa

extension MainProjectListVC: ProjectListMenuDelegate {
    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int) {
        guard projectInfos.indices.contains(row) else { return }
        let projectInfo = projectInfos[row]
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }
        ToolsOutlineWC.show(project: projectInfo)
    }

    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int) {
        if let view = projectListTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
            if let v = view as? ProjectListCellView {
                v.projectNameLable.becomeFirstResponder()
            }
        }
    }

    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int) {
        ProjectInfoManager.shared.remove(at: row, type: .list)
        let indexSets = IndexSet(integer: row)
        projectListTableView.removeRows(at: indexSets, withAnimation: .slideDown)
    }

    func projectListMenuNeedsUpdate(_ menu: NSMenu) {
        projectListMenu.refreshMenu(menu)
    }
}
