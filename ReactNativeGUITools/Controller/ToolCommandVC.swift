import Cocoa

class ToolCommandVC: NSViewController, ProjectInfoAssignable {
    var projectInfo: ProjectInfo? { didSet {
        if oldValue?.id != projectInfo?.id || oldValue?.path != projectInfo?.path { runner?.cancel(); runner = nil; projectDidChange(); if isViewLoaded { reloadOperations() } }
    } }
    var makeRunner: () -> ToolRunning = { StreamingToolRunner() }
    var operationProvider: (ProjectInfo) throws -> [ToolOperation] { fatalError("Override") }
    var planBuilder: (String, [String: String], ProjectInfo) throws -> ToolPlan { fatalError("Override") }
    var readyStatus: String { "Ready. Commands run in the selected project." }
    func projectDidChange() {}
    var panel: ToolConsoleView { view as! ToolConsoleView }
    private var options: [ToolOperation] = []
    private var runner: ToolRunning?
    private var token = UUID()
    private var log = Data()
    private var closeObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        panel.onOperation = { [weak self] id in self?.selectOperation(id) }
        panel.onRun = { [weak self] in self?.runOperation() }
        panel.onCancel = { [weak self] in self?.runner?.cancel() }
        panel.onBrowse = { [weak self] id, save in self?.browse(id: id, save: save) }
        reloadOperations()
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        if let closeObserver = closeObserver { NotificationCenter.default.removeObserver(closeObserver) }
        closeObserver = NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: view.window, queue: .main) { [weak self] _ in self?.runner?.cancel() }
    }
    func reloadOperations() {
        let id = UUID(); token = id
        guard let project = projectInfo else { panel.status.stringValue = "Open a project first."; panel.running(false); panel.runButton.isEnabled = false; return }
        let provider = operationProvider
        panel.status.stringValue = "Loading operations…"; panel.runButton.isEnabled = false
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let result = Result { try provider(project) }
            DispatchQueue.main.async {
                guard let self = self, self.token == id else { return }
                switch result {
                case .success(let options):
                    let previous = self.panel.operation
                    self.options = options; self.panel.configure(options, selected: previous)
                    self.selectOperation(self.panel.operation ?? "")
                    self.panel.status.stringValue = self.readyStatus
                case .failure(let error): self.panel.status.stringValue = error.localizedDescription
                }
                self.panel.running(false)
            }
        }
    }
    func selectOperation(_ id: String) {
        if let item = panel.operations.itemArray.first(where: { $0.representedObject as? String == id }) { panel.operations.select(item) }
        panel.showFields(options.first { $0.id == id }?.fields ?? [])
    }
    func runOperation() {
        guard runner == nil, let project = projectInfo, let operation = panel.operation else { return }
        do {
            let plan = try planBuilder(operation, panel.values, project)
            guard !plan.commands.isEmpty else { throw ToolInputError(message: "No commands to run.") }
            let run = makeRunner(); runner = run
            let id = UUID(); token = id; log = Data(); panel.console.string = ""
            panel.status.stringValue = "Running…"; panel.running(true)
            run.run(plan, onOutput: { [weak self] data in
                guard let self = self, self.token == id else { return }
                self.log.append(data)
                if self.log.count > 1_000_000 { self.log.removeFirst(self.log.count - 1_000_000) }
                self.panel.console.string = String(decoding: self.log, as: UTF8.self)
                self.panel.console.scrollToEndOfDocument(nil)
            }, completion: { [weak self] result in
                guard let self = self, self.token == id else { return }
                self.runner = nil; self.panel.running(false)
                self.panel.status.stringValue = result.cancelled ? "Cancelled" : result.exitCode == 0 ? "Completed successfully" : "Command failed (exit \(result.exitCode)). See output."
                self.didComplete(operation: operation, result: result)
                if result.exitCode == 0 && !result.cancelled, let output = plan.outputDirectory { NSWorkspace.shared.open(URL(fileURLWithPath: output)) }
            })
        } catch { panel.status.stringValue = error.localizedDescription }
    }
    func didComplete(operation: String, result: ToolRunResult) {}
    private func browse(id: String, save: Bool) {
        guard let window = view.window else { return }
        let panel: NSSavePanel = save ? NSSavePanel() : NSOpenPanel()
        if let open = panel as? NSOpenPanel { open.canChooseFiles = true; open.canChooseDirectories = false; open.allowsMultipleSelection = false }
        panel.beginSheetModal(for: window) { [weak self] result in
            if result == .OK, let path = panel.url?.path { self?.panel.setValue(path, for: id) }
        }
    }
    deinit { runner?.cancel(); if let closeObserver = closeObserver { NotificationCenter.default.removeObserver(closeObserver) } }
}
