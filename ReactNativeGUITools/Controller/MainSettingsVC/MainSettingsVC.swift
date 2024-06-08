//
//  MainSettingsVC.swift0//  ReactNativeGUITools
//
//  Created by Tejas on 02/06/24.
//

import Cocoa

class MainSettingsVC: NSViewController {
    // MARK: - Properties

    @IBOutlet var tabView: NSTabView!

    @IBOutlet var codeEditorPathPopupMenu: NSPopUpButton!
    @IBOutlet var codeEditorPathLabel: NSTextField!

    @IBOutlet var xcodePathPopupMenu: NSPopUpButton!
    @IBOutlet var xcodePathLabel: NSTextField!

    @IBOutlet var androidStudioPopupMenu: NSPopUpButton!
    @IBOutlet var androidStudioPathLabel: NSTextField!

    private var codeEditorPaths: [PathVersion] = []
    private var xcodePaths: [PathVersion] = []
    private var androidStudioPaths: [PathVersion] = []

    private let mainSettingsMainager = MainSettingsManager.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopupMenuItems()
        selectDefaultItems()
    }

    // MARK: - Setup

    private func setupPopupMenuItems() {
        codeEditorPaths = mainSettingsMainager.mainSettings.getCodeEditorsaths()
        codeEditorPathPopupMenu.addItems(withTitles: codeEditorPaths.map { $0.description })

        xcodePaths = mainSettingsMainager.mainSettings.getXcodesPaths()
        xcodePathPopupMenu.addItems(withTitles: xcodePaths.map { $0.description })

        androidStudioPaths = mainSettingsMainager.mainSettings.getAndroidStudioPaths()
        androidStudioPopupMenu.addItems(withTitles: androidStudioPaths.map { $0.description })
    }

    private func selectDefaultItems() {
        if let defaultCodeEditor = mainSettingsMainager.mainSettings.defaultCodeEditor {
            codeEditorPathPopupMenu.selectItem(withTitle: defaultCodeEditor.description)
            codeEditorPathLabel.stringValue = defaultCodeEditor.path
        }
        if let defaultXcode = mainSettingsMainager.mainSettings.defaultXcodePath {
            xcodePathPopupMenu.selectItem(withTitle: defaultXcode.description)
            xcodePathLabel.stringValue = defaultXcode.path
        }
        if let defaultAndroidStudio = mainSettingsMainager.mainSettings.defaultAndroidStudio {
            androidStudioPopupMenu.selectItem(withTitle: defaultAndroidStudio.description)
            androidStudioPathLabel.stringValue = defaultAndroidStudio.path
        }
    }

    // MARK: - Actions

    @IBAction func codeEditorPopUpButtonSelectionChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        mainSettingsMainager.setDefaultCodeEditor(item: codeEditorPaths[index])
        codeEditorPathLabel.stringValue = codeEditorPaths[index].path
    }

    @IBAction func xcodePopUpButtonSelectionChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        mainSettingsMainager.setDefaultXcodePath(item: codeEditorPaths[index])
        xcodePathLabel.stringValue = codeEditorPaths[index].path
    }

    @IBAction func androidStudioPopUpButtonSelectionChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        mainSettingsMainager.setDefaultAndroidStudio(item: codeEditorPaths[index])
        androidStudioPathLabel.stringValue = codeEditorPaths[index].path
    }

    @IBAction func codeEditorShowInFinder(_ sender: Any) {
        guard let path = mainSettingsMainager.mainSettings.defaultCodeEditor?.path else { return }
        let fileExists = FileManager.default.fileExists(atPath: path)
        if !fileExists {
            return
        }
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    @IBAction func xcodeShowInFinder(_ sender: Any) {
        guard let path = mainSettingsMainager.mainSettings.defaultXcodePath?.path else { return }
        let fileExists = FileManager.default.fileExists(atPath: path)
        if !fileExists {
            return
        }
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    @IBAction func androidStudioShowInFinder(_ sender: Any) {
        guard let path = mainSettingsMainager.mainSettings.defaultAndroidStudio?.path else { return }
        let fileExists = FileManager.default.fileExists(atPath: path)
        if !fileExists {
            return
        }
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    // MARK: - Helpers
}
