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
                if let projectPath = self.projectInfo?.path, selectedPath.hasPrefix(projectPath) {
                    let relativePath = String(selectedPath.dropFirst(projectPath.count))
                    let cleanPath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
                    self.scriptTextField.stringValue = "$PROJECT_ROOT/\(cleanPath)"
                } else {
                    self.scriptTextField.stringValue = selectedPath
                }
            }
        }
    }

    @IBAction func onPressCancel(_ sender: NSButton) {
        self.dismiss(self)
    }

    @IBAction func onPressOkay(_ sender: NSButton) {
        let name = menuNameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let script = scriptTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            NSSound.beep()
            menuNameTextField.becomeFirstResponder()
            return
        }

        guard !script.isEmpty else {
            NSSound.beep()
            scriptTextField.becomeFirstResponder()
            return
        }

        let isFileScript = script.hasPrefix("/") || script.hasPrefix("$PROJECT_ROOT") || script.hasPrefix("./")
        let id = customScriptToEdit?.id ?? UUID().uuidString
        let result = ProjectInfo.CustomMenuScript(id: id, name: name, script: script, isFileScript: isFileScript)
        onSave?(result)
        self.dismiss(self)
    }
}
