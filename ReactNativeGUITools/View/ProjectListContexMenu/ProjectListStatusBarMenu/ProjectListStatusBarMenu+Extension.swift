//
//  ProjectListStatusBarMenu+Extension.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

extension ProjectListStatusBarMenu {
    func promptForReply(_ inputValue: String, _ message: String, _ informativeText: String, completion: @escaping PromptAlertView.promptResponseClosure) {
        let promptView = PromptAlertView(inputValue: inputValue, message: message, informativeText: informativeText)
        let (responseText, userResponse) = promptView.displayAlert()
        completion(responseText, userResponse)
    }
}

extension ProjectListStatusBarMenu: NSMenuDelegate {
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        projectListMenu.setClickedRow(item?.tag)
    }
}

extension ProjectListStatusBarMenu: ProjectListMenuDelegate {
    func projectListMenuNeedsUpdate(_ menu: NSMenu) {}
    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int) {}

    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int) {
        let projectInfo = projectInfoCollection.projectInfos[row]
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }
        if let foundController = NSWindowController.getAllControllers().compactMap({ $0 as? ToolsOutlineWC }).first(where: { $0.fromRow == row }) {
            foundController.window?.makeKeyAndOrderFront(self)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateController(withIdentifier: "ToolsOutlineWC") as? ToolsOutlineWC else { return }
            controller.fromRow = row
            controller.projectInfo = projectInfo
            controller.showWindow(nil)
            controller.window?.makeKeyAndOrderFront(self)
        }
    }

    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int) {
        let projectInfo = projectInfoCollection.projectInfos[row]
        let projectName = (projectInfo.name ?? "")

        promptForReply(projectName, "Rename?", "Rename \(projectName)", completion: { (newName: String, bResponse: Bool) in
            if bResponse {
                let projectInfo = ProjectInfoCollection.shared.projectInfos[row]
                let newName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !newName.isEmpty {
                    projectInfo.name = newName
                    ProjectInfoCollection.shared.update(with: projectInfo)
                }
            }
        })
    }
}
