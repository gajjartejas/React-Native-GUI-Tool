//
//  CustomActionsVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 30/06/24.
//

import Cocoa

class CustomActionsVC: NSViewController, ProjectInfoAssignable {
    var projectInfo: ProjectInfo? {
        didSet {
            customActionsTableView?.reloadData()
            updateButtonStates()
        }
    }

    @IBOutlet var customActionsTableView: NSTableView!
    @IBOutlet var editButton: NSButton!
    @IBOutlet var removeButton: NSButton!
    @IBOutlet var moveSegmentedControl: NSSegmentedControl!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializecustomActionsTableView()
        updateButtonStates()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        customActionsTableView.reloadData()
        updateButtonStates()
    }

    private func initializecustomActionsTableView() {
        customActionsTableView.register(CustomActionsCellView.nib(inBundle: .main),
                                        forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: CustomActionsCellView.self)))
        customActionsTableView.registerForDraggedTypes([.tableViewIndex])
        customActionsTableView.delegate = self
        customActionsTableView.dataSource = self
        customActionsTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        customActionsTableView.sizeLastColumnToFit()
        customActionsTableView.doubleAction = #selector(onTableDoubleClicked(_:))
        customActionsTableView.target = self
    }

    @objc func onTableDoubleClicked(_ sender: Any) {
        if customActionsTableView.selectedRow >= 0 {
            onPressEditCustomAction(NSButton())
        }
    }

    func updateButtonStates() {
        let selectedRow = customActionsTableView?.selectedRow ?? -1
        let count = projectInfo?.customMenuScripts?.count ?? 0
        let hasSelection = selectedRow >= 0 && selectedRow < count
        editButton?.isEnabled = hasSelection
        removeButton?.isEnabled = hasSelection
        moveSegmentedControl?.setEnabled(hasSelection && selectedRow > 0, forSegment: 0)
        moveSegmentedControl?.setEnabled(hasSelection && selectedRow < count - 1, forSegment: 1)
    }

    // MARK: - Actions

    @IBAction func onPressAddNewCustomAction(_ sender: NSButton) {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = mainStoryboard.instantiateController(withIdentifier: "AddCustomActionVC") as? AddCustomActionVC else {
            return
        }
        vc.projectInfo = projectInfo
        vc.onSave = { [weak self] newScript in
            guard let self = self, let projectInfo = self.projectInfo else { return }
            if projectInfo.customMenuScripts == nil {
                projectInfo.customMenuScripts = []
            }
            projectInfo.customMenuScripts?.append(newScript)
            ProjectInfoManager.shared.update(with: projectInfo)
            self.customActionsTableView.reloadData()
            let newIndex = (projectInfo.customMenuScripts?.count ?? 1) - 1
            self.customActionsTableView.selectRowIndexes(IndexSet(integer: newIndex), byExtendingSelection: false)
            self.updateButtonStates()
        }
        self.presentAsSheet(vc)
    }

    @IBAction func onPressEditCustomAction(_ sender: NSButton) {
        let selectedRow = customActionsTableView.selectedRow
        guard selectedRow >= 0, let customMenuScripts = projectInfo?.customMenuScripts, selectedRow < customMenuScripts.count else {
            return
        }
        let scriptToEdit = customMenuScripts[selectedRow]
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = mainStoryboard.instantiateController(withIdentifier: "AddCustomActionVC") as? AddCustomActionVC else {
            return
        }
        vc.projectInfo = projectInfo
        vc.customScriptToEdit = scriptToEdit
        vc.onSave = { [weak self] updatedScript in
            guard let self = self, let projectInfo = self.projectInfo else { return }
            projectInfo.customMenuScripts?[selectedRow] = updatedScript
            ProjectInfoManager.shared.update(with: projectInfo)
            self.customActionsTableView.reloadData()
            self.customActionsTableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
            self.updateButtonStates()
        }
        self.presentAsSheet(vc)
    }

    @IBAction func onPressRemoveCustomAction(_ sender: NSButton) {
        let selectedRow = customActionsTableView.selectedRow
        guard selectedRow >= 0, let count = projectInfo?.customMenuScripts?.count, selectedRow < count else {
            return
        }
        projectInfo?.customMenuScripts?.remove(at: selectedRow)
        if let projectInfo = projectInfo {
            ProjectInfoManager.shared.update(with: projectInfo)
        }
        customActionsTableView.reloadData()
        if let newCount = projectInfo?.customMenuScripts?.count, newCount > 0 {
            let nextIndex = min(selectedRow, newCount - 1)
            customActionsTableView.selectRowIndexes(IndexSet(integer: nextIndex), byExtendingSelection: false)
        }
        updateButtonStates()
    }

    @IBAction func onPressMoveUpDown(_ sender: NSSegmentedControl) {
        let selectedRow = customActionsTableView.selectedRow
        guard selectedRow >= 0, var scripts = projectInfo?.customMenuScripts else { return }

        let destinationRow = sender.selectedSegment == 0 ? selectedRow - 1 : selectedRow + 1
        guard destinationRow >= 0 && destinationRow < scripts.count else { return }

        scripts.swapAt(selectedRow, destinationRow)
        projectInfo?.customMenuScripts = scripts
        if let projectInfo = projectInfo {
            ProjectInfoManager.shared.update(with: projectInfo)
        }
        customActionsTableView.reloadData()
        customActionsTableView.selectRowIndexes(IndexSet(integer: destinationRow), byExtendingSelection: false)
        updateButtonStates()
    }
}
