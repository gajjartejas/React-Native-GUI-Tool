//
//  ProjectTabViewController.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 19/04/24.
//

import Cocoa

class ProjectTabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedTabViewItemIndex = 0

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectionChange(_:)),
            name: Notification.Name(ToolsOutlineVC.NotificationNames.selectionChanged),
            object: nil)
    }

    @objc
    private func handleSelectionChange(_ notification: Notification) {
        if let selectedIndex = notification.userInfo?["index"] as? Int {
            selectedTabViewItemIndex = selectedIndex
        }
    }
}
