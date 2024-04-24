//
//  MainProjectListVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/03/24.
//

import Cocoa

var projects: [ProjectInfo] = [
    ProjectInfo(name: "Calculator", path: "/Users/your_username/Desktop/Calculator", versionString: "1.0"),
    ProjectInfo(name: "Notes", path: "/Users/your_username/Desktop/Notes", versionString: "2.0"),
    ProjectInfo(name: "Reminder", path: "/Users/your_username/Desktop/Reminder", versionString: "3.0"),
    ProjectInfo(name: "Photos", path: "/Users/your_username/Desktop/Photos", versionString: "1.5"),
    ProjectInfo(name: "Music", path: "/Users/your_username/Desktop/Music", versionString: "2.5"),
]

class MainProjectListVC: NSViewController {
    // MARK: - Properties

    @IBOutlet var projectListTableView: NSTableView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeProjectListTableView()

        let menu = initializeContexMenu()
        projectListTableView.menu = menu
    }


    // MARK: - Helpers

    private func initializeProjectListTableView() {
        projectListTableView.register(ProjectListCellView.nib(inBundle: .main),
                                      forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ProjectListCellView.self)))
        projectListTableView.delegate = self
        projectListTableView.dataSource = self

        projectListTableView.registerForDraggedTypes([.fileURL, .pdf, .png, .string])

        // self.projectListTableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        projectListTableView.setDraggingSourceOperationMask([.copy, .delete], forLocal: false)
        projectListTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        projectListTableView.tableColumns[0].resizingMask = .autoresizingMask
        projectListTableView.sizeLastColumnToFit()
    }
}
