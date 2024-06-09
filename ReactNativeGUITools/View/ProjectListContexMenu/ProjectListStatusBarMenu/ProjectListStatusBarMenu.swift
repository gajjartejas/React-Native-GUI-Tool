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
            menuItem.submenu = projectListMenu.createMenuFrom(row: row)
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
            menuItem.submenu = projectListMenu.createMenuFrom(row: row)
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
