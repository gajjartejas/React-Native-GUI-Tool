//
//  ProjectListContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 19/05/24.
//

import Cocoa

class ProjectListStatusBarMenu: NSObject {
    var statusBarItem: NSStatusItem!
    let statusBarMenu = NSMenu()
    let projectListMenu = ProjectListMenu()
    var projectInfos: [ProjectInfo]!

    override private init() {
        super.init()
    }

    convenience init(projectInfos: [ProjectInfo]) {
        self.init()
        self.projectInfos = projectInfos
        createProjectListMenu()
    }

    private func createProjectListMenu() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = .init(named: "status-bar-icon")?.tint(color: .red)
        statusBarItem.button?.image?.isTemplate = true

        // Open
        let openMenuItem = NSMenuItem(title: "Show Main Window", action: #selector(showUIAction(_:)), keyEquivalent: "")
        openMenuItem.tag = -1
        statusBarMenu.addItem(openMenuItem)

        statusBarMenu.addItem(NSMenuItem.separator())

        // Project List
        for (row, info) in projectInfos.enumerated() {
            let menuItem = NSMenuItem(title: info.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.submenu = projectListMenu.createMenuFrom(projectInfos: projectInfos, row: row)
            menuItem.tag = row
            statusBarMenu.addItem(menuItem)
        }

        statusBarMenu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(settingsAction(_:)), keyEquivalent: "")
        settingsItem.tag = -5
        statusBarMenu.addItem(settingsItem)

        // Github
        let githubItem = NSMenuItem(title: "Github", action: #selector(githubAction(_:)), keyEquivalent: "")
        githubItem.tag = -4
        statusBarMenu.addItem(githubItem)

        // Sponsor
        let sponsorItem = NSMenuItem(title: "Sponsor", action: #selector(sponsorAction(_:)), keyEquivalent: "")
        sponsorItem.tag = -3
        statusBarMenu.addItem(sponsorItem)

        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitUIAction(_:)), keyEquivalent: "")
        quitItem.tag = -2
        statusBarMenu.addItem(quitItem)

        statusBarMenu.delegate = self
        statusBarMenu.setTargetToSelfRecursively(target: projectListMenu)
        settingsItem.target = self
        openMenuItem.target = self
        githubItem.target = self
        sponsorItem.target = self
        quitItem.target = self
        statusBarItem.menu = statusBarMenu

        projectListMenu.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadMenu),
                                               name: ProjectInfoManager.NotificationNames.projectInfoDidChange,
                                               object: nil)
    }

    @objc func reloadMenu() {
        statusBarMenu.removeAllItems()

        // get latest
        projectInfos = ProjectInfoManager.shared.get(type: .menu)

        // Open
        let openMenuItem = NSMenuItem(title: "Show Main Window", action: #selector(showUIAction(_:)), keyEquivalent: "")
        openMenuItem.tag = -1
        statusBarMenu.addItem(openMenuItem)

        statusBarMenu.addItem(NSMenuItem.separator())

        for (row, info) in projectInfos.enumerated() {
            let menuItem = NSMenuItem(title: info.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.submenu = projectListMenu.createMenuFrom(projectInfos: projectInfos, row: row)
            menuItem.tag = row
            statusBarMenu.addItem(menuItem)
        }

        statusBarMenu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(settingsAction(_:)), keyEquivalent: "")
        settingsItem.tag = -5
        statusBarMenu.addItem(settingsItem)

        // Github
        let githubItem = NSMenuItem(title: "Github", action: #selector(githubAction(_:)), keyEquivalent: "")
        githubItem.tag = -4
        statusBarMenu.addItem(githubItem)

        // Sponsor
        let sponsorItem = NSMenuItem(title: "Sponsor", action: #selector(sponsorAction(_:)), keyEquivalent: "")
        sponsorItem.tag = -3
        statusBarMenu.addItem(sponsorItem)

        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitUIAction(_:)), keyEquivalent: "")
        quitItem.tag = -2
        statusBarMenu.addItem(quitItem)

        statusBarMenu.delegate = self
        statusBarMenu.setTargetToSelfRecursively(target: projectListMenu)

        settingsItem.target = self
        openMenuItem.target = self
        githubItem.target = self
        sponsorItem.target = self
        quitItem.target = self

        statusBarItem.menu = statusBarMenu
    }

    @objc func showUIAction(_ sender: NSMenuItem) {
        let allWC = NSWindowController.getAllControllers()
        if let window = allWC.first?.window {
            window.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitUIAction(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }

    @objc func sponsorAction(_ sender: NSMenuItem) {
        let url = "https://github.com/sponsors/gajjartejas"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func githubAction(_ sender: NSMenuItem) {
        let url = "https://github.com/gajjartejas/React-Native-GUI-Tool"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func settingsAction(_ sender: NSMenuItem) {
        let allControllers = NSWindowController.getAllControllers()
        if let foundController = allControllers.compactMap({ $0 as? MainSettingsWC }).first {
            foundController.window?.makeKeyAndOrderFront(self)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateController(withIdentifier: "MainSettingsWC") as? MainSettingsWC else { return }
            if let mainWindow = allControllers.first?.window {
                controller.location = mainWindow.frame
            }
            controller.window?.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
