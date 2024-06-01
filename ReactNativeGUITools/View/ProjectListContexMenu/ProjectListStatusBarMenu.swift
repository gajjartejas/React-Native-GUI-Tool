//
//  ProjectListContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 19/05/24.
//

import Cocoa

class ProjectListStatusBarMenu: NSObject {
    var projectInfoCollection: ProjectInfoCollection!
    var statusBarItem: NSStatusItem!
    let statusBarMenu = NSMenu()
    let projectListMenu = ProjectListMenu()

    func createMenu(projectInfoCollection: ProjectInfoCollection) {
        self.projectInfoCollection = projectInfoCollection

        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = .init(named: "status-bar-icon")?.tint(color: .red)
        statusBarItem.button?.image?.isTemplate = true

        // Open
        let openMenuItem = NSMenuItem(title: "Show Main Window", action: #selector(showUI(_:)), keyEquivalent: "")
        openMenuItem.tag = -1
        statusBarMenu.addItem(openMenuItem)

        // Project List
        for (row, info) in projectInfoCollection.projectInfos.enumerated() {
            let menuItem = NSMenuItem(title: info.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.submenu = projectListMenu.createMenuFrom(from: projectInfoCollection, row: row)
            menuItem.tag = row
            statusBarMenu.addItem(menuItem)
        }

        // Open
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitUI(_:)), keyEquivalent: "")
        quitItem.tag = -2
        statusBarMenu.addItem(quitItem)

        statusBarMenu.delegate = self
        statusBarMenu.setTargetToSelfRecursively(target: projectListMenu)
        openMenuItem.target = self
        quitItem.target = self
        statusBarItem.menu = statusBarMenu

        projectListMenu.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadMenu),
                                               name: ProjectInfoCollection.NotificationNames.projectInfoDidChange,
                                               object: nil)
    }

    @objc func showUI(_ sender: NSMenuItem) {
        NSApplication.shared.activate(ignoringOtherApps: true)

        let allWC = NSWindowController.getAllControllers()
        if let window = allWC.first?.window {
            window.makeKeyAndOrderFront(self)
        }
    }

    @objc func quitUI(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }

    @objc func reloadMenu() {
        statusBarMenu.removeAllItems() // Remove all existing items

        for (row, info) in projectInfoCollection.projectInfos.enumerated() {
            let menuItem = NSMenuItem(title: info.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.submenu = projectListMenu.createMenuFrom(from: projectInfoCollection, row: row)
            menuItem.tag = row
            statusBarMenu.addItem(menuItem)
        }

        statusBarMenu.delegate = self
        statusBarMenu.setTargetToSelfRecursively(target: projectListMenu)
        statusBarItem.menu = statusBarMenu
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

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
