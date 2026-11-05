import Cocoa

final class SystemInfoVC: NSViewController {
    var makeScanner: () -> SystemDiagnosticsScanning = { SystemDiagnosticsScanner() }
    var writeReportToPasteboard: (String) -> Void = { report in
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report, forType: .string)
    }
    private var scanner: SystemDiagnosticsScanning?
    private var report: SystemDiagnosticsReport?
    private var systemView: SystemInfoView { view as! SystemInfoView }

    override func viewDidLoad() {
        super.viewDidLoad()
        systemView.onRefresh = { [weak self] in self?.refreshDiagnostics() }
        systemView.onCopy = { [weak self] in self?.copyDiagnostics() }
        systemView.render(report: "Run diagnostics to inspect installed tools.", status: "Ready", isScanning: false, canCopy: false)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if report == nil && scanner == nil { refreshDiagnostics() }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        guard let scanner = scanner else { return }
        scanner.cancel()
        self.scanner = nil
        systemView.render(report: report?.text ?? "Run diagnostics to inspect installed tools.",
                          status: "Scan cancelled. Refresh to run diagnostics.", isScanning: false, canCopy: report != nil)
    }

    func refreshDiagnostics() {
        scanner?.cancel()
        let current = makeScanner()
        scanner = current
        systemView.render(report: report?.text ?? "Scanning development tools…", status: "Scanning… Commands have an 8-second timeout.", isScanning: true, canCopy: report != nil)
        current.scan { [weak self, weak current] report in
            guard let self = self, let current = current, self.scanner === current else { return }
            self.report = report
            self.scanner = nil
            self.systemView.render(report: report.text,
                                   status: "Scan complete. \(report.attentionCount) checks need attention. Copy the report to share diagnostics.",
                                   isScanning: false, canCopy: true)
        }
    }

    func copyDiagnostics() {
        guard let report = report else { return }
        writeReportToPasteboard(report.text)
    }

    deinit { scanner?.cancel() }
}
