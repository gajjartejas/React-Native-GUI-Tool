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

        return menu
    }

    // MARK: - Actions

    @objc func menuItemAction(_ sender: NSMenuItem) {
        switch sender.title {
        case "Always on top":
            sender.state = sender.state == .on ? .off : .on
            view.window?.level = sender.state == .on ? .floating : .normal

        default:
            break
        }
    }
}
