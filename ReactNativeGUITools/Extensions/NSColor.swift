//
//  NSColor.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 18/05/24.
//

import Cocoa

extension NSColor {
    static func color(for projectName: String?) -> NSColor {
        guard let projectName = projectName else {
            return NSColor.gray
        }
        func darkenedColorFromHash(_ string: String) -> NSColor {
            var hash: UInt64 = 5381
            for char in string.utf8 {
                hash = ((hash << 5) &+ hash) &+ UInt64(char)
            }
            hash = hash & 0x00FFFFFF
            let color = NSColor(red: CGFloat((hash & 0xFF0000) >> 16) / 255.0,
                                green: CGFloat((hash & 0x00FF00) >> 8) / 255.0,
                                blue: CGFloat(hash & 0x0000FF) / 255.0,
                                alpha: 1.0)
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return NSColor(hue: hue, saturation: saturation, brightness: max(brightness - 0.2, 0.0), alpha: alpha)
        }

        return darkenedColorFromHash(projectName)
    }
}
