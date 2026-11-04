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
            print(projectInfo.debugDescription)
        }
    }

    @IBOutlet var customActionsTableView: NSTableView!

    // MARK: - Properties

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializecustomActionsTableView()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func initializecustomActionsTableView() {
        customActionsTableView.register(CustomActionsCellView.nib(inBundle: .main),
                                        forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: CustomActionsCellView.self)))
        customActionsTableView.delegate = self
        customActionsTableView.dataSource = self
        customActionsTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        customActionsTableView.sizeLastColumnToFit()
    }

    // MARK: - Setup

    // MARK: - Actions

    @IBAction func onPressAddNewCustomAction(_ sender: NSButton) {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = mainStoryboard.instantiateController(withIdentifier: "AddCustomActionVC") as? AddCustomActionVC else {
            return
        }
        self.presentAsSheet(vc)
    }

    // MARK: - Helpers
}
