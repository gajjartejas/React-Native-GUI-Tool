//
//  ProjectListCellView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

class ToolsOutlineCellView: NSTableCellView, NibInstantiatable {
    // MARK: - Properties

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var leftIconImageView: NSImageView!

    // MARK: - Lifecycle

    // MARK: - Drawing Method

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // MARK: - Actions

    // MARK: - Helpers

    func configureUI(withNode node: MenuNode) {
        titleLabel.stringValue = node.title

        if node.nodeType == .group {
            leftIconImageView.isHidden = true

            titleLabel.textColor = .gray
            titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        } else {
            leftIconImageView.isHidden = false

            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 12, weight: .regular)

            if node.iconName != nil {
                leftIconImageView.image = NSImage(named: node.iconName!)

                leftIconImageView.contentTintColor = .controlAccentColor // .white//
            }
        }
    }
}
