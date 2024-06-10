//
//  MainSettingsWC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

class MainSettingsWC: NSWindowController {
    static var firstTabSelectIdentifier = "General"
    static var secondTabSelectIdentifier = "Locations"
    @IBOutlet var toolBar: NSToolbar!

    var location: NSRect? {
        didSet {
            if let location = location {
                self.centerWindow(relativeTo: location)
            }
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        track()
        setupToolBar()
    }

    @IBAction func toolBarAction(_ sender: NSToolbarItem) {
        tabViewSelect(withIdentifier: sender.itemIdentifier)
    }

    func tabViewSelect(withIdentifier identifier: Any) {
        let vc = contentViewController as! MainSettingsVC
        vc.tabView.selectTabViewItem(withIdentifier: identifier)
    }

    func setupToolBar() {
        let identifier = NSToolbarItem.Identifier(rawValue: MainSettingsWC.secondTabSelectIdentifier)
        toolBar.selectedItemIdentifier = identifier
        tabViewSelect(withIdentifier: identifier)
        toolBar.allowsUserCustomization = false
    }

    deinit {
        self.remove()
    }
}

extension MainSettingsWC: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
