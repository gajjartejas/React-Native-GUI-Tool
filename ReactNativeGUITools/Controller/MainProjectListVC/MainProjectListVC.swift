//
//  MainProjectListVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/03/24.
//

import Cocoa

class MainProjectListVC: NSViewController {
    // MARK: - Properties

    @IBOutlet var projectListTableView: NSTableView!
    @IBOutlet var dropView: DropView!
    @IBOutlet var projectSearchTextField: NSSearchField!

    var projectInfoCollection = ProjectInfoCollection()

    var searching: Bool {
        let searchString = projectSearchTextField.stringValue
        let pureString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        return pureString.count > 0
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeProjectListTableView()

        let menu = initializeContexMenu()
        projectListTableView.menu = menu

        initializeDropHandler()

        projectSearchTextField.delegate = self

        projectInfoCollection.onChangeProjectInfo = { [self] in
            checkForEmptyData()
        }
        checkForEmptyData()
    }

    // MARK: - Helpers

    func checkForEmptyData() {
        if projectInfoCollection.projectInfosAll.isEmpty && !searching {
            dropView.isHidden = false
        } else {
            dropView.isHidden = true
        }
    }

    private func initializeProjectListTableView() {
        projectListTableView.register(ProjectListCellView.nib(inBundle: .main),
                                      forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ProjectListCellView.self)))
        projectListTableView.delegate = self
        projectListTableView.dataSource = self
        projectListTableView.registerForDraggedTypes([.fileURL])
        projectListTableView.setDraggingSourceOperationMask([.copy, .delete], forLocal: false)
        projectListTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        projectListTableView.tableColumns[0].resizingMask = .autoresizingMask
        projectListTableView.sizeLastColumnToFit()
        projectListTableView.style = .inset
    }

    private func initializeDropHandler() {
        dropView.dragging { folderPath in
            let newProject = ProjectInfo(id: UUID().uuidString, path: folderPath)
            self.projectInfoCollection.append(newProject)
            self.projectListTableView.reloadData()
        }

        dropView.leftClick {
            let openPanel = NSOpenPanel()
            openPanel.title = "Select Project(s)"
            openPanel.message = "Select react native project folder(s)"
            openPanel.showsResizeIndicator = true
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.allowsMultipleSelection = true
            openPanel.canCreateDirectories = true
            openPanel.begin { [self] result in
                if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                    let newProjects = openPanel.urls.map { item in
                        let folderPath = item.path
                        let newProject = ProjectInfo(id: UUID().uuidString, path: folderPath)
                        return newProject
                    }
                    self.projectInfoCollection.append(contentsOf: newProjects)
                    self.projectListTableView.reloadData()
                }
            }
        }
    }
}