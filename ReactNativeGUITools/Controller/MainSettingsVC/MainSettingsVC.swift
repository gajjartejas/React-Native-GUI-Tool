//
//  MainSettingsVC.swift0//  ReactNativeGUITools
//
//  Created by Tejas on 02/06/24.
//

import Cocoa

class MainSettingsVC: NSViewController {
    // MARK: - Properties

    @IBOutlet var tabView: NSTabView!
    @IBOutlet var loginView: LoginSettingsView!
    var loginService: LoginItemManaging = LoginItemService()
    var openLoginSettings: () -> Void = LoginItemService.openSettings
    private var loginRequest = UUID()

    @IBOutlet var codeEditorPathPopupMenu: NSPopUpButton!
    @IBOutlet var codeEditorPathLabel: NSTextField!

    @IBOutlet var xcodePathPopupMenu: NSPopUpButton!
    @IBOutlet var xcodePathLabel: NSTextField!

    @IBOutlet var androidStudioPopupMenu: NSPopUpButton!
    @IBOutlet var androidStudioPathLabel: NSTextField!

    private let mainSettingsMainager = MainSettingsManager.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopupMenuItems()
        selectDefaultItems()
        loginView.onChange = { [weak self] in self?.updateLogin(enabled: $0) }
        loginView.onOpenSettings = { [weak self] in self?.openLoginSettings() }
        updateLogin(enabled: nil)
    }

    func updateLogin(enabled: Bool?) {
        let token = UUID(); loginRequest = token
        let service = loginService
        loginView.toggle.isEnabled = false
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var failure: String?
            do { if let enabled = enabled { try service.setEnabled(enabled) } }
            catch { failure = error.localizedDescription }
            let state = service.state
            DispatchQueue.main.async {
                guard let self = self, self.loginRequest == token else { return }
                let value: NSControl.StateValue = state == .enabled ? .on : state == .approvalRequired ? .mixed : .off
                self.loginView.render(state: value, message: failure.map { "Unable to change login item: " + $0 } ?? state.message, busy: false)
            }
        }
    }

    // MARK: - Setup

    private func setupPopupMenuItems() {
        configurePopup(codeEditorPathPopupMenu, items: mainSettingsMainager.mainSettings.getCodeEditorsaths())
        configurePopup(xcodePathPopupMenu, items: mainSettingsMainager.mainSettings.getXcodesPaths())
        configurePopup(androidStudioPopupMenu, items: mainSettingsMainager.mainSettings.getAndroidStudioPaths())
    }

    private func configurePopup(_ popup: NSPopUpButton, items: [PathVersion]) {
        popup.removeAllItems()
        for item in items {
            popup.addItem(withTitle: item.description)
            popup.lastItem?.representedObject = item
        }
        popup.isEnabled = !items.isEmpty
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
        guard let item = sender.selectedItem?.representedObject as? PathVersion else { return }
        mainSettingsMainager.setDefaultCodeEditor(item: item)
        codeEditorPathLabel.stringValue = item.path
    }

    @IBAction func xcodePopUpButtonSelectionChanged(_ sender: NSPopUpButton) {
        guard let item = sender.selectedItem?.representedObject as? PathVersion else { return }
        mainSettingsMainager.setDefaultXcodePath(item: item)
        xcodePathLabel.stringValue = item.path
    }

    @IBAction func androidStudioPopUpButtonSelectionChanged(_ sender: NSPopUpButton) {
        guard let item = sender.selectedItem?.representedObject as? PathVersion else { return }
        mainSettingsMainager.setDefaultAndroidStudio(item: item)
        androidStudioPathLabel.stringValue = item.path
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
