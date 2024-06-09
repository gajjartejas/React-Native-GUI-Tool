//
//  MainProjectListVC+Delegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 23/04/24.
//

import Cocoa

extension MainProjectListVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let cellView = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(
                    rawValue: String(describing: ProjectListCellView.self)),
                owner: self) as? ProjectListCellView
        else {
            return nil
        }

        cellView.configureUI(withNode: ProjectInfoCollection.shared.projectInfos[row], atRow: row)
        cellView.delegate = self
        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44
    }

    func tableView(
        _ tableView: NSTableView,
        pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        return ProjectListPasteboardWriter(project: ProjectInfoCollection.shared.projectInfos[row].name ?? "-", at: row)
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
        if searching { return false }
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }

        let oldIndexes = items.compactMap { $0.integer(forType: .tableViewIndex) }
        if !oldIndexes.isEmpty {
            ProjectInfoCollection.shared.move(fromOffsets: IndexSet(oldIndexes), toOffset: row)
            // The ol' Stack Overflow copy-paste. Reordering rows can get pretty hairy if
            // you allow multiple selection. https://stackoverflow.com/a/26855499/7471873

            tableView.beginUpdates()
            var oldIndexOffset = 0
            var newIndexOffset = 0

            for oldIndex in oldIndexes {
                if oldIndex < row {
                    tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                    oldIndexOffset -= 1
                } else {
                    tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                    newIndexOffset += 1
                }
            }
            tableView.endUpdates()

            return true
        }

        let newProjects = items.compactMap { item in
            ProjectInfo(id: UUID().uuidString, path: item.url(forType: .fileURL)!)
        }

        for newProject in newProjects {
            if ProjectInfoCollection.shared.findByPath(project: newProject) {
                showConfirmAlert(
                    message: "Duplicate Project",
                    informativeText: "A project with the same path already exists. Do you want to add it again?",
                    confirmAction: {
                        ProjectInfoCollection.shared.insert(contentsOf: [newProject], at: row)
                        tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideDown)
                    },
                    cancelAction: {}
                )
                return true
            } else {
                ProjectInfoCollection.shared.insert(contentsOf: newProjects, at: row)
                tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideDown)
            }
        }
        return true
    }

    func tableView(
        _ tableView: NSTableView,
        draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation) {
        if operation == .delete, let items = session.draggingPasteboard.pasteboardItems {
            let indexes = items.compactMap { $0.integer(forType: .tableViewIndex) }
            for index in indexes.reversed() {
                ProjectInfoCollection.shared.remove(at: index)
            }
            tableView.removeRows(at: IndexSet(indexes), withAnimation: .slideUp)
        }
    }
}

extension MainProjectListVC {
    func showConfirmAlert(message: String, informativeText: String, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        _ = ConfirmAlertView(
            message: message,
            informativeText: informativeText,
            confirmButtonTitle: "OK",
            cancelButtonTitle: "Cancel",
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
    }
}
