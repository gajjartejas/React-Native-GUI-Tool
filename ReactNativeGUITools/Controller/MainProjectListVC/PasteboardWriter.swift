//
//  ProjectListPasteboardWriter.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 08/04/24.
//

import Cocoa

class ProjectListPasteboardWriter: NSObject, NSPasteboardWriting {
    var project: String
    var index: Int

    init(project: String, at index: Int) {
        self.project = project
        self.index = index
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.fileURL, .tableViewIndex]
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .fileURL:
            return project
        case .tableViewIndex:
            return index
        default:
            return nil
        }
    }
}
