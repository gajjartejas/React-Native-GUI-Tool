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
    @IBOutlet var moreButton: NSButton!

    let projectListMenu = ProjectListMenu()

    var searching: Bool {
        let searchString = projectSearchTextField.stringValue
        let pureString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        return pureString.count > 0
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeProjectListTableView()

        projectListTableView.menu = projectListMenu.createMenuFrom(row: nil)
        projectListMenu.delegate = self

        // more contex menu
        moreButton.menu = initializeMoreContexMenu()

        initializeDropHandler()

        projectSearchTextField.delegate = self

        checkForEmptyData()
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)

        setupRightClickMonitor()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkForEmptyData),
                                               name: ProjectInfoManager.NotificationNames.projectInfoDidChange,
                                               object: nil)
    }

    var rightClickMonitor: Any?

    deinit {
        if let rightClickMonitor = rightClickMonitor {
            NSEvent.removeMonitor(rightClickMonitor)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func setupRightClickMonitor() {
        rightClickMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            self?.handleRightClick(event: event)
            return event
        }
    }

    func handleRightClick(event: NSEvent) {
        let pointInWindow = event.locationInWindow
        let pointInTable = projectListTableView.convert(pointInWindow, from: nil)
        let clickedRow = projectListTableView.row(at: pointInTable)
        if clickedRow != -1 {
            projectListMenu.setClickedRow(clickedRow)
        } else {
            projectListMenu.setClickedRow(nil)
        }
    }

    @objc func viewDidBecomeActive() {
        projectListTableView.reloadData()
    }

    // MARK: - Actions

    @IBAction func onPressMoreButton(_ sender: NSButton) {
        let location = NSPoint(x: 0, y: sender.bounds.height + 4)
        sender.menu?.popUp(positioning: nil, at: location, in: sender)
    }

    @IBAction func onPressGithubLinkButton(_ sender: Any) {
        let url = "https://github.com/gajjartejas/React-Native-GUI-Tool"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @IBAction func onPressGithubDonateLinkButton(_ sender: Any) {
        let url = "https://github.com/sponsors/gajjartejas"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    // MARK: - Helpers

    @objc func checkForEmptyData() {
        if ProjectInfoManager.shared.projectInfosAll.isEmpty && !searching {
            dropView.isHidden = false
        } else {
            dropView.isHidden = true
        }
        projectListTableView.reloadData()
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
        projectListTableView.doubleAction = #selector(openAction)
    }

    @objc func openAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let row = projectListTableView.clickedRow
        let projectInfo = ProjectInfoManager.shared.projectInfos[row]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }

        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }
        let allControllers = NSWindowController.getAllControllers()
        if let foundController = NSWindowController.getAllControllers().compactMap({ $0 as? ToolsOutlineWC }).first(where: { $0.fromRow == row }) {
            foundController.window?.makeKeyAndOrderFront(self)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateController(withIdentifier: "ToolsOutlineWC") as? ToolsOutlineWC else { return }
            controller.fromRow = row
            controller.projectInfo = projectInfo
            if let mainWindow = allControllers.first?.window {
                controller.location = mainWindow.frame
            }
            controller.window?.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    private func initializeDropHandler() {
        dropView.dragging { folderPath in
            let newProject = ProjectInfo(id: UUID().uuidString, path: folderPath)
            ProjectInfoManager.shared.append(newProject)
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
                    ProjectInfoManager.shared.append(contentsOf: newProjects)
                    self.projectListTableView.reloadData()
                }
            }
        }
    }
}
