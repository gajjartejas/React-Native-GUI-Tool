//
//  AddCustomActionVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 22/09/24.
//

import Cocoa

class AddCustomActionVC: NSViewController {

    @IBOutlet var menuNameTextField: NSTextField!
    @IBOutlet var scriptTextField: NSTextField!

    var projectInfo: ProjectInfo?
    var customScriptToEdit: ProjectInfo.CustomMenuScript?
    var onSave: ((ProjectInfo.CustomMenuScript) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let script = customScriptToEdit {
            menuNameTextField.stringValue = script.name
            scriptTextField.stringValue = script.script
        }
    }

    @IBAction func onPressBrowseScript(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        if let projectPath = projectInfo?.path {
            openPanel.directoryURL = URL(fileURLWithPath: projectPath)
        }
        guard let window = self.view.window else { return }
        openPanel.beginSheetModal(for: window) { [weak self] response in
            guard let self = self else { return }
            if response == .OK, let selectedURL = openPanel.url {
                let selectedPath = selectedURL.path
                self.scriptTextField.stringValue = self.projectInfo?.customScriptPath(for: selectedPath) ?? selectedPath
            }
        }
    }

    @IBAction func onPressCancel(_ sender: NSButton) {
        self.dismiss(self)
    }

    @IBAction func onPressOkay(_ sender: NSButton) {
        do {
            let result = try ProjectInfo.CustomMenuScript.validated(
                name: menuNameTextField.stringValue,
                script: scriptTextField.stringValue,
                id: customScriptToEdit?.id
            )
            onSave?(result)
            self.dismiss(self)
        } catch ProjectInfo.CustomMenuScript.ValidationError.emptyName {
            NSSound.beep()
            menuNameTextField.becomeFirstResponder()
        } catch {
            NSSound.beep()
            scriptTextField.becomeFirstResponder()
        }
    }
}
