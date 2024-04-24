//
//  ProjectListCellView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

class ProjectListCellView: NSTableCellView, NibInstantiatable {
    // MARK: - Properties

    @IBOutlet var projectLogo: NSImageView!
    @IBOutlet var projectNameLable: NSTextField!
    @IBOutlet var projectPathLable: NSTextField!
    @IBOutlet var projectVersion: NSTextField!

    // MARK: - Lifecycle

    // MARK: - Drawing Method

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // MARK: - Actions

    // MARK: - Helpers

    func configureUI(withNode project: ProjectInfo) {
        projectNameLable.stringValue = project.name
        projectPathLable.stringValue = project.path
    }
}
