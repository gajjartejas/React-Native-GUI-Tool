//
//  CustomActionsVC+Delegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 03/07/24.
//

import Cocoa

extension CustomActionsVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let cellView = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(
                    rawValue: String(describing: CustomActionsCellView.self)),
                owner: self) as? CustomActionsCellView
        else {
            return nil
        }

        guard let customMenuScripts = self.projectInfo?.customMenuScripts else {
            return nil
        }
        cellView.configureUI(with: customMenuScripts[row], atRow: row)
        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }

    func tableView(
        _ tableView: NSTableView,
        validateDrop info: NSDraggingInfo,
        proposedRow row: Int,
        proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        guard dropOperation == .above else { return [] }

        // If dragging to reorder, use the gap feedback style. Otherwise, draw insertion marker.
        if let source = info.draggingSource as? NSTableView, source === tableView {
            tableView.draggingDestinationFeedbackStyle = .regular
        } else {
            tableView.draggingDestinationFeedbackStyle = .regular
        }
        return .move
    }

    func tableView(
        _ tableView: NSTableView,
        acceptDrop info: NSDraggingInfo,
        row: Int,
        dropOperation: NSTableView.DropOperation) -> Bool {
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }

        let oldIndexes = items.compactMap { $0.integer(forType: .tableViewIndex) }
        if !oldIndexes.isEmpty {
            ProjectInfoManager.shared.move(fromOffsets: IndexSet(oldIndexes), toOffset: row)
            return true
        }

        return true
    }
}
