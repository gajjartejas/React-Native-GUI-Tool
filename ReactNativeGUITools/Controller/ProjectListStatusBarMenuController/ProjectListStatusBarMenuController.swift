//
//  ProjectListContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 19/05/24.
//

import Cocoa

class ProjectListStatusBarMenuController: NSObject {
    var statusBarItem: NSStatusItem!
    let statusBarMenu = NSMenu()
    let projectListMenu = ProjectListMenuController()
    let searchView = StatusMenuSearchView()
    var projectInfos: [ProjectInfo]!

    override private init() {
        super.init()
    }

    convenience init(projectInfos: [ProjectInfo]) {
        self.init()
        self.projectInfos = projectInfos
        createProjectListMenuController()
    }

    private func createProjectListMenuController() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = .init(named: "status-bar-icon")?.tint(color: .red)
        statusBarItem.button?.image?.isTemplate = true

        let search = NSMenuItem()
        search.view = searchView
        search.tag = -20
        statusBarMenu.addItem(search)
        searchView.onSearch = { query in ProjectInfoManager.shared.searchBy(query, type: .menu) }
        let openMenuItem = NSMenuItem(title: "Show Main Window", action: #selector(showUIAction(_:)), keyEquivalent: "")
        openMenuItem.tag = -1
        statusBarMenu.addItem(openMenuItem)
        statusBarMenu.addItem(NSMenuItem.separator())
        insertProjectItems()

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

    func menuWillOpen(_ menu: NSMenu) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.searchView.window?.makeFirstResponder(self.searchView.searchField)
        }
    }

    @objc func reloadMenu() {
        projectInfos = ProjectInfoManager.shared.get(type: .menu)
        // Keep the search view attached while the menu is tracking keyboard input.
        for item in statusBarMenu.items where item.tag >= 0 && !item.isSeparatorItem || item.tag == -10 {
            statusBarMenu.removeItem(item)
        }
        insertProjectItems()
    }

    private func insertProjectItems() {
        if projectInfos.isEmpty {
            let empty = NSMenuItem(title: "No matching projects", action: nil, keyEquivalent: "")
            empty.tag = -10
            statusBarMenu.insertItem(empty, at: 3)
        }
        for (row, info) in projectInfos.enumerated() {
            let item = NSMenuItem(title: info.name ?? "-", action: nil, keyEquivalent: "")
            item.submenu = projectListMenu.createMenuFrom(projectInfos: projectInfos, row: row)
            item.tag = row
            statusBarMenu.insertItem(item, at: 3 + row)
        }
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
