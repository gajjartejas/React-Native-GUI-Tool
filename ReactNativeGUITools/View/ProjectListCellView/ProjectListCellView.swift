//
//  ProjectListCellView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

class ProjectListCellView: NSTableCellView, NibInstantiatable {
    // MARK: - Properties

    @IBOutlet var projectLogoView: NSView!
    @IBOutlet var projectLogoLable: NSTextField!
    @IBOutlet var projectNameLable: NSTextField!
    @IBOutlet var projectPathLable: NSTextField!
    @IBOutlet var projectVersion: NSTextField!
    @IBOutlet var projectVersionLable: NSView!
    
    var index: Int?
    weak var delegate: ProjectListCellViewDelegate?

    // MARK: - Lifecycle

    // MARK: - Drawing Method

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // MARK: - Actions

    @IBAction func onPressShowInFolder(_ sender: NSButton) {
        if let index = index {
            delegate?.showInFolder(atIndex: index)
        }
    }

    @IBAction func textEdited(_ sender: NSTextField) {
        if let index = index {
            delegate?.textEdited(text: sender.stringValue, atIndex: index)
        }
    }

    // MARK: - Helpers

    func configureUI(withNode project: ProjectInfo, atRow row: Int) {
        projectNameLable.stringValue = project.name ?? "-"
        projectPathLable.stringValue = project.path
        projectVersion.stringValue = project.versionString ?? "-"
        projectVersionLable.cornerRadius = 4.0
        projectVersionLable.backgroundColor = .init(named: "control-1")
        projectLogoView.cornerRadius = 26.0
        projectLogoView.backgroundColor = NSColor.color(for: project.name)
        projectLogoLable.stringValue = getShortenedString(from: project.name)
        index = row
    }
}

protocol ProjectListCellViewDelegate: AnyObject {
    func textEdited(text: String, atIndex index: Int)
    func showInFolder(atIndex index: Int)
}
