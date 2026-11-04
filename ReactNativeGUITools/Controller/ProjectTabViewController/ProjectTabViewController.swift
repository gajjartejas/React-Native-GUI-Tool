//
//  ProjectTabViewController.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 19/04/24.
//

import Cocoa

protocol ProjectInfoAssignable {
    var projectInfo: ProjectInfo? { get set }
}

class ProjectTabViewController: NSTabViewController {
    var projectInfo: ProjectInfo? {
        didSet {
            for child in self.children {
                if var assignable = child as? ProjectInfoAssignable {
                    assignable.projectInfo = projectInfo
                }
            }
        }
    }

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
