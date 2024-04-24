//
//  ToolsOutlineVC+Delegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 23/04/24.
//

import Cocoa

extension ToolsOutlineVC: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView,
                            viewFor tableColumn: NSTableColumn?,
                            item: Any) -> NSView? {
        guard
            let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ToolsOutlineCellView.self)), owner: self) as? ToolsOutlineCellView,
            let node = item as? MenuNode
        else {
            return nil
        }

        cellView.configureUI(withNode: node)

        return cellView
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let node = item as? MenuNode else {
            return false
        }

        return node.nodeType == .parent
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow
        guard let node = outlineView.item(atRow: selectedIndex) as? MenuNode else {
            return
        }

        print("Selected Title: \(node.title)")

        NotificationCenter.default.post(
            name: Notification.Name(ToolsOutlineVC.NotificationNames.selectionChanged),
            object: nil,
            userInfo: ["index": node.index])
    }
}
