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

        cellView.configureUI(withNode: projectInfos[row], atRow: row)
        cellView.delegate = self
        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44
    }

    func tableView(
        _ tableView: NSTableView,
        pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        return ProjectListPasteboardWriter(project: projectInfos[row].name ?? "-", at: row)
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
            ProjectInfoManager.shared.move(fromOffsets: IndexSet(oldIndexes), toOffset: row)
            return true
        }

        let newProjects = items.compactMap { item in
            ProjectInfo(id: UUID().uuidString, path: item.url(forType: .fileURL)!)
        }

        for newProject in newProjects {
            if ProjectInfoManager.shared.findByPath(project: newProject, type: .list) {
                showConfirmAlert(
                    message: "Duplicate Project",
                    informativeText: "A project \(newProject.name ?? "") with the same path already exists. Do you want to add it again?",
                    confirmAction: {
                        ProjectInfoManager.shared.insert(contentsOf: [newProject], at: row)
                    },
                    cancelAction: {}
                )
                return true
            } else {
                ProjectInfoManager.shared.insert(contentsOf: newProjects, at: row)
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
                ProjectInfoManager.shared.remove(at: index, type: .list)
            }
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
