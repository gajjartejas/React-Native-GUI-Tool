//
//  NSPasteboardItem.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 24/04/24.
//

import Cocoa

extension NSPasteboardItem {
    func integer(forType type: NSPasteboard.PasteboardType) -> Int? {
        guard let data = data(forType: type) else { return nil }
        let plist = try? PropertyListSerialization.propertyList(
            from: data,
            options: .mutableContainers,
            format: nil)
        return plist as? Int
    }

    func url(forType type: NSPasteboard.PasteboardType) -> String? {
        guard let data = data(forType: type) else { return nil }
        guard let stringURL = String(data: data, encoding: .utf8) else { return nil }
        guard let url = URL(string: stringURL) else { return nil }
        return url.relativePath
    }
}
