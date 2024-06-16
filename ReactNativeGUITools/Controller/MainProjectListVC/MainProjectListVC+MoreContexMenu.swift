//
//  MainProjectListVC+MoreContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 18/05/24.
//

import Cocoa

extension MainProjectListVC {
    func initializeMoreContexMenu() -> NSMenu {
        let menu = NSMenu()

        let menuItems = [
            ("Always on top", #selector(alwaysOnTopAction(_:)), "", 1),
            ("Sort by Name", #selector(sortByNameAction(_:)), "", 2),
            ("Sort by Path", #selector(sortByPathAction(_:)), "", 3),
            ("Sort by Version", #selector(sortByVersionAction(_:)), "", 4),
            ("Settings...", #selector(settingsAction(_:)), "", 5),
            ("Github", #selector(githubAction(_:)), "", 6),
            ("Sponsor", #selector(sponsorAction(_:)), "", 7),
            ("Quit", #selector(quitUIAction(_:)), "", 8),
        ]

        for (index, item) in menuItems.enumerated() {
            if index == 1 || index == 4 {
                menu.addItem(NSMenuItem.separator())
            }
            let menuItem = NSMenuItem(title: item.0, action: item.1, keyEquivalent: item.2)
            menuItem.tag = item.3
            if item.0 == "Always on top" {
                menuItem.state = .off
            }
            menuItem.target = self
            menu.addItem(menuItem)
        }

        return menu
    }

    // MARK: - Actions

    @objc func alwaysOnTopAction(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        view.window?.level = sender.state == .on ? .floating : .normal
    }

    @objc func sortByNameAction(_ sender: NSMenuItem) {
        ProjectInfoManager.shared.sorted(by: .name)
    }

    @objc func sortByPathAction(_ sender: NSMenuItem) {
        ProjectInfoManager.shared.sorted(by: .path)
    }

    @objc func sortByVersionAction(_ sender: NSMenuItem) {
        ProjectInfoManager.shared.sorted(by: .versionString)
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

    @objc func githubAction(_ sender: NSMenuItem) {
        let url = "https://github.com/gajjartejas/React-Native-GUI-Tool"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func sponsorAction(_ sender: NSMenuItem) {
        let url = "https://github.com/sponsors/gajjartejas"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func quitUIAction(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
}
