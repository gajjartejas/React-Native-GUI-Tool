//
//  NSWindowController.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 28/05/24.
//

import Cocoa

extension NSWindowController {
    private static var allActiveControllers = [NSWindowController]()
    private static var allControllers = [NSWindowController]()

    func track() {
        NSWindowController.allControllers.append(self)
        NSWindowController.allActiveControllers.append(self)
    }

    func untrack() {
        if let index = NSWindowController.allActiveControllers.firstIndex(of: self) {
            NSWindowController.allActiveControllers.remove(at: index)
        }
    }

    func remove() {
        if let index = NSWindowController.allControllers.firstIndex(of: self) {
            NSWindowController.allControllers.remove(at: index)
            NSWindowController.allActiveControllers.remove(at: index)
        }
    }

    static func getAllControllers() -> [NSWindowController] {
        return allControllers
    }

    static func getAllActiveControllers() -> [NSWindowController] {
        return allControllers.filter { $0.window?.isVisible == true }
    }
}

extension NSWindowController {
    func centerWindow(relativeTo parentFrame: NSRect) {
        guard let window = window else { return }

        let windowSize = window.frame.size

        let centeredX = parentFrame.origin.x + (parentFrame.size.width - windowSize.width) / 2
        let centeredY = parentFrame.origin.y + (parentFrame.size.height - windowSize.height) / 2

        let centeredOrigin = CGPoint(x: centeredX, y: centeredY)
        window.setFrameOrigin(centeredOrigin)
    }
}
