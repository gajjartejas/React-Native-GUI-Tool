//
//  NSMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 21/05/24.
//

import Cocoa

extension NSMenuItem {
    func setTargetToSelfRecursively(target: AnyObject?) {
        self.target = target
        if let submenu = submenu {
            submenu.setTargetToSelfRecursively(target: target)
        }
    }
}

extension NSMenu {
    func setTargetToSelfRecursively(target: AnyObject?) {
        for item in items {
            item.target = target
            item.setTargetToSelfRecursively(target: target)
            if let submenu = item.submenu {
                submenu.setTargetToSelfRecursively(target: target)
            }
        }
    }
}
