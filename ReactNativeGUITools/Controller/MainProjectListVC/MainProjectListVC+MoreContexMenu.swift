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

        // Setup the menu items
        let alwaysOnTopItem = NSMenuItem(title: "Always on top", action: #selector(menuItemAction(_:)), keyEquivalent: "")
        alwaysOnTopItem.state = .off
        alwaysOnTopItem.target = self
        menu.addItem(alwaysOnTopItem)

        menu.addItem(NSMenuItem.separator())

        let sortByNameItem = NSMenuItem(title: "Sort by Name", action: #selector(menuItemAction(_:)), keyEquivalent: "")
        sortByNameItem.target = self
        menu.addItem(sortByNameItem)

        let sortByPathItem = NSMenuItem(title: "Sort by Path", action: #selector(menuItemAction(_:)), keyEquivalent: "")
        sortByPathItem.target = self
        menu.addItem(sortByPathItem)

        let sortByVersionItem = NSMenuItem(title: "Sort by Version", action: #selector(menuItemAction(_:)), keyEquivalent: "")
        sortByVersionItem.target = self
        menu.addItem(sortByVersionItem)

        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(menuItemAction(_:)), keyEquivalent: "")
        refreshItem.target = self
        menu.addItem(refreshItem)

        return menu
    }

    // MARK: - Actions

    @objc func menuItemAction(_ sender: NSMenuItem) {
        switch sender.title {
        case "Always on top":
            sender.state = sender.state == .on ? .off : .on
            view.window?.level = sender.state == .on ? .floating : .normal
        case "Sort by Name":
            self.projectInfoCollection.sorted(by: .name)
            projectListTableView.reloadData()
        case "Sort by Path":
            self.projectInfoCollection.sorted(by: .path)
            projectListTableView.reloadData()
        case "Sort by Version":
            self.projectInfoCollection.sorted(by: .versionString)
            projectListTableView.reloadData()
        case "Refresh":
            print("Refresh selected")
        default:
            break
        }
    }
}
