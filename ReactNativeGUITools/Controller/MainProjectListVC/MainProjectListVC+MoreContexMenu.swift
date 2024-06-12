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
            ("Always on top", #selector(menuItemAction(_:)), "", 1),
            ("Sort by Name", #selector(menuItemAction(_:)), "", 2),
            ("Sort by Path", #selector(menuItemAction(_:)), "", 3),
            ("Sort by Version", #selector(menuItemAction(_:)), "", 4),
            ("Refresh", #selector(menuItemAction(_:)), "", 5)
        ]
        
        for (index, item) in menuItems.enumerated() {
            if index == 1 || index == 5 {
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

    @objc func menuItemAction(_ sender: NSMenuItem) {
        switch sender.tag {
        case 1: // Always on top
            sender.state = sender.state == .on ? .off : .on
            view.window?.level = sender.state == .on ? .floating : .normal
        case 2: // Sort by Name
            ProjectInfoManager.shared.sorted(by: .name)
            projectListTableView.reloadData()
        case 3: // Sort by Path
            ProjectInfoManager.shared.sorted(by: .path)
            projectListTableView.reloadData()
        case 4: // Sort by Version
            ProjectInfoManager.shared.sorted(by: .versionString)
            projectListTableView.reloadData()
        case 5: // Refresh
            projectListTableView.reloadData()
        default:
            break
        }
    }
}
