import Cocoa

final class ProjectInfoVC: NSViewController, ProjectInfoAssignable, NSTableViewDataSource, NSTableViewDelegate {
    var projectInfo: ProjectInfo? { didSet { if isViewLoaded { reload() } } }
    var performShortcut: ((ProjectShortcut, ProjectInfo) -> Void)?
    private var metadata: ProjectMetadata?
    private var rows: [ProjectMetadata.Dependency] = []
    private var request = UUID()
    private let menuController = ProjectListMenuController()
    private var panel: ProjectInfoPanel { view as! ProjectInfoPanel }

    override func viewDidLoad() {
        super.viewDidLoad()
        panel.table.dataSource = self; panel.table.delegate = self
        panel.onSearch = { [weak self] _ in self?.filter() }
        panel.onShortcut = { [weak self] in self?.shortcut($0) }
        reload()
    }

    func reload() {
        let token = UUID(); request = token
        metadata = nil; rows = []; panel.table.reloadData()
        guard let project = projectInfo else { panel.status.stringValue = "Open a project to inspect its metadata."; return }
        panel.summary.string = "Loading…"; panel.status.stringValue = "Reading package.json and native identifiers…"
        let path = project.path
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let result = Result { try ProjectMetadata.read(path: path) }
            DispatchQueue.main.async {
                guard let self = self, self.request == token else { return }
                switch result {
                case .success(let value):
                    self.metadata = value; self.panel.summary.string = value.summary
                    self.panel.status.stringValue = "\(value.dependencies.count) dependencies. Native build-setting expressions are shown as declared."
                    self.filter()
                case .failure(let error):
                    self.panel.summary.string = "Unable to read project metadata."
                    self.panel.status.stringValue = error.localizedDescription
                }
            }
        }
    }
    private func filter() { rows = metadata?.filtered(panel.search.stringValue) ?? []; panel.table.reloadData() }
    func numberOfRows(in tableView: NSTableView) -> Int { rows.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard rows.indices.contains(row) else { return nil }
        let dependency = rows[row]
        return NSTextField(labelWithString: tableColumn?.identifier.rawValue == "name" ? dependency.name : tableColumn?.identifier.rawValue == "version" ? dependency.version : dependency.scope)
    }
    private func shortcut(_ shortcut: ProjectShortcut) {
        guard let project = projectInfo else { return }
        if shortcut == .refresh { reload(); return }
        if let performShortcut = performShortcut { performShortcut(shortcut, project); return }
        guard FileManager.default.fileExists(atPath: project.path) else { panel.status.stringValue = "Project directory is missing."; return }
        if shortcut == .editor && MainSettingsManager.shared.mainSettings.defaultCodeEditor == nil || shortcut == .xcode && MainSettingsManager.shared.mainSettings.defaultXcodePath == nil || shortcut == .android && MainSettingsManager.shared.mainSettings.defaultAndroidStudio == nil {
            panel.status.stringValue = "Select a default application in Settings → Locations first."; return
        }
        _ = menuController.createMenuFrom(projectInfos: [project], row: 0)
        let item = NSMenuItem()
        switch shortcut {
        case .finder: menuController.showInFinderAction(item)
        case .terminal: menuController.openInTerminalAction(item)
        case .editor: menuController.openInCodeEditorAction(item)
        case .xcode: menuController.openInXcodeAction(item)
        case .android: menuController.openInAndroidStudioAction(item)
        case .refresh: break
        }
    }
}
