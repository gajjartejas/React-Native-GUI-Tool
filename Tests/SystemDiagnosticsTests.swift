import Cocoa

final class ControlledDiagnosticsScanner: SystemDiagnosticsScanning {
    var completion: ((SystemDiagnosticsReport) -> Void)?
    var cancellations = 0
    func scan(completion: @escaping (SystemDiagnosticsReport) -> Void) { self.completion = completion }
    func cancel() { cancellations += 1 }
    func finish(_ report: SystemDiagnosticsReport) {
        let callback = completion
        completion = nil
        callback?(report)
    }
}

enum SystemDiagnosticsTests {
    static func run(directory: URL) throws {
        let paths = SystemDiagnosticsReport.searchPaths(environment: ["PATH": ":relative:/fixture:/fixture"], home: directory.path)
        precondition(paths.first == "/fixture" && Set(paths).count == paths.count && !paths.contains("relative"))
        precondition(SystemDiagnosticsReport.androidSDKPath(environment: ["ANDROID_HOME": "/sdk", "ANDROID_SDK_ROOT": "/other"], home: "/home") == "/sdk")
        precondition(SystemDiagnosticsReport.androidSDKPath(environment: ["ANDROID_HOME": "", "ANDROID_SDK_ROOT": "/other"], home: "/home") == "/other")
        precondition(SystemDiagnosticsReport.androidSDKPath(environment: [:], home: "/home") == "/home/Library/Android/sdk")
        let scanner = SystemDiagnosticsScanner(environment: ["PATH": "/usr/bin:/bin"], home: directory.path, timeout: 0.1)
        let literal = "space ' quote \" $HOME; Ω"
        let result = scanner.run(.init(title: "Literal arguments", executable: "/usr/bin/printf", arguments: ["%s", literal]))
        precondition(result.status == .available && result.detail == literal)
        let missing = scanner.run(.init(title: "Missing", executable: "rngui-not-a-real-tool", arguments: []))
        precondition(missing.status == .missing && missing.detail.contains("PATH"))
        let failure = scanner.run(.init(title: "Failure", executable: "/usr/bin/false", arguments: []))
        precondition(failure.status == .failed)
        let began = Date()
        let timeout = scanner.run(.init(title: "Timeout", executable: "/bin/sleep", arguments: ["5"]))
        precondition(timeout.status == .timedOut && Date().timeIntervalSince(began) < 2)
        scanner.cancel()
        let cancelled = scanner.run(.init(title: "Cancelled", executable: "/usr/bin/printf", arguments: ["should not run"]))
        precondition(cancelled.status == .failed && cancelled.detail == "Cancelled")
        let running = SystemDiagnosticsScanner(home: directory.path, timeout: 10)
        let marker = directory.appendingPathComponent("diagnostic-started")
        let helper = directory.appendingPathComponent("diagnostic-helper.sh")
        try Data(("#!/bin/sh\nprintf started > " + shellQuoted(marker.path) + "\nexec /bin/sleep 5\n").utf8).write(to: helper)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: helper.path)
        let completed = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let stopped = running.run(.init(title: "In-flight cancellation", executable: helper.path, arguments: []))
            precondition(stopped.status == .failed)
            completed.signal()
        }
        let startDeadline = Date(timeIntervalSinceNow: 2)
        while !FileManager.default.fileExists(atPath: marker.path) && Date() < startDeadline { Thread.sleep(forTimeInterval: 0.01) }
        precondition(FileManager.default.fileExists(atPath: marker.path), "Test process never started")
        running.cancel()
        precondition(completed.wait(timeout: .now() + 2) == .success, "Cancelled process did not exit")
        let report = SystemDiagnosticsReport(results: [result, missing, failure, timeout])
        precondition(report.attentionCount == 3)
        precondition(report.text.contains("Missing [Not found]") && report.text.contains("Timeout [Timed out]"))
        print("PASS: diagnostic discovery policy, direct arguments, missing tools, failures, timeout, cancellation, and report formatting")
    }

    @MainActor
    static func liveScan(home: String) throws -> SystemDiagnosticsReport {
        let scanner = SystemDiagnosticsScanner(home: home)
        var report: SystemDiagnosticsReport?
        scanner.scan { report = $0 }
        let deadline = Date(timeIntervalSinceNow: 120)
        while report == nil && Date() < deadline { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05)) }
        guard let report = report else {
            scanner.cancel()
            throw CocoaError(.executableRuntimeMismatch)
        }
        precondition(report.results.count == 13)
        precondition(report.results.first?.title == "macOS")
        print("PASS: live read-only diagnostics completed (\(report.results.count) checks)")
        print(report.text)
        return report
    }
}
