//
//  CustomActionsVC+Delegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 03/07/24.
//

import Cocoa

final class CustomActionPasteboardWriter: NSObject, NSPasteboardWriting {
    let index: Int

    init(index: Int) {
        self.index = index
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.tableViewIndex]
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == .tableViewIndex {
            return index
        }
        return nil
    }
}

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

        guard let customMenuScripts = self.projectInfo?.customMenuScripts, row < customMenuScripts.count else {
            return nil
        }

        let item = customMenuScripts[row]
        if tableColumn?.identifier.rawValue == "scriptColumn" {
            cellView.configureUI(with: item.script)
        } else {
            cellView.configureUI(with: item.name)
        }

        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 22
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        return CustomActionPasteboardWriter(index: row)
    }

    func tableView(
        _ tableView: NSTableView,
        validateDrop info: NSDraggingInfo,
        proposedRow row: Int,
        proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        guard dropOperation == .above else { return [] }
        tableView.draggingDestinationFeedbackStyle = .regular
        return .move
    }

    func tableView(
        _ tableView: NSTableView,
        acceptDrop info: NSDraggingInfo,
        row: Int,
        dropOperation: NSTableView.DropOperation) -> Bool {
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }

        let oldIndexes = items.compactMap { $0.integer(forType: .tableViewIndex) }
        guard let sourceIndex = oldIndexes.first, let projectInfo = projectInfo else { return false }

        var destination = row
        if destination > sourceIndex {
            destination -= 1
        }
        guard projectInfo.moveCustomScript(from: sourceIndex, to: destination) else { return false }
        ProjectInfoManager.shared.update(with: projectInfo)
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: destination), byExtendingSelection: false)
        updateButtonStates()
        return true
    }
}
