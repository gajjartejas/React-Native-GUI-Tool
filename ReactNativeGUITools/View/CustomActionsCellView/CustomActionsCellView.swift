//
//  CustomActionsCellView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

class CustomActionsCellView: NSTableCellView, NibInstantiatable {
    // MARK: - Properties

    @IBOutlet var titleLabel: NSTextField!

    // MARK: - Lifecycle

    // MARK: - Drawing Method

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // MARK: - Helpers

    func configureUI(with text: String) {
        titleLabel.stringValue = text
    }
}
