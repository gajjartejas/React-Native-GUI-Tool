//
//  ProjectListStatusBarMenuController+Extension.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

extension ProjectListStatusBarMenuController {
    func promptForReply(_ inputValue: String, _ message: String, _ informativeText: String, completion: @escaping PromptAlertView.promptResponseClosure) {
        let promptView = PromptAlertView(inputValue: inputValue, message: message, informativeText: informativeText)
        let (responseText, userResponse) = promptView.displayAlert()
        completion(responseText, userResponse)
    }
}

extension ProjectListStatusBarMenuController: NSMenuDelegate {
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        projectListMenu.setClickedRow(item?.tag)
    }
}

extension ProjectListStatusBarMenuController: ProjectListMenuDelegate {
    func projectListMenuNeedsUpdate(_ menu: NSMenu) {}
    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int) {
        ProjectInfoManager.shared.remove(at: row, type: .menu)
    }

    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int) {
        guard projectInfos.indices.contains(row) else { return }
        let projectInfo = projectInfos[row]
        
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }

        ToolsOutlineWC.show(project: projectInfo)
    }

    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int) {
        let projectInfo = projectInfos[row]
        let projectName = (projectInfo.name ?? "")

        promptForReply(projectName, "Rename?", "Rename \(projectName)", completion: { (newName: String, bResponse: Bool) in
            if bResponse, projectInfo.rename(to: newName) {
                ProjectInfoManager.shared.update(with: projectInfo)
            }
        })
    }
}
