import Foundation
import Darwin

/// Direct process arguments only: no shell startup files, package scripts, or installs.
final class SystemDiagnosticsScanner: SystemDiagnosticsScanning {
    private let environment: [String: String]
    private let home: String
    private let timeout: TimeInterval
    private let lock = NSLock()
    private var cancelled = false
    private var activeProcess: Process?

    init(environment: [String: String] = ProcessInfo.processInfo.environment,
         home: String = FileManager.default.homeDirectoryForCurrentUser.path,
         timeout: TimeInterval = 8) {
        self.home = home
        self.timeout = timeout
        var environment = environment
        environment["PATH"] = SystemDiagnosticsReport.searchPaths(environment: environment, home: home).joined(separator: ":")
        environment["COCOAPODS_DISABLE_STATS"] = "true"
        environment["COREPACK_ENABLE_NETWORK"] = "0"
        environment["CI"] = "true"
        self.environment = environment
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let process = activeProcess
        lock.unlock()
        if process?.isRunning == true { process?.terminate() }
    }

    private var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }

    func scan(completion: @escaping (SystemDiagnosticsReport) -> Void) {
        DispatchQueue.global(qos: .utility).async { [self] in
            let report = collect()
            guard !isCancelled else { return }
            DispatchQueue.main.async {
                guard !self.isCancelled else { return }
                completion(report)
            }
        }
    }

    private func collect() -> SystemDiagnosticsReport {
        var results = [DiagnosticResult(title: "macOS", status: .available,
                                        detail: ProcessInfo.processInfo.operatingSystemVersionString)]
        let arm = run(.init(title: "CPU", executable: "/usr/sbin/sysctl", arguments: ["-n", "hw.optional.arm64"]))
        let architecture = run(.init(title: "CPU architecture", executable: "/usr/bin/uname", arguments: ["-m"]))
        results.append(.init(title: "CPU architecture", status: architecture.status,
                             detail: arm.status == .available && arm.detail == "1"
                                ? "Apple Silicon (process: \(architecture.detail))"
                                : architecture.detail == "x86_64" ? "Intel (x86_64)" : architecture.detail))
        for check in SystemDiagnosticsReport.toolChecks where !isCancelled { results.append(run(check)) }

        let developer = run(.init(title: "Command-line tools", executable: "/usr/bin/xcode-select", arguments: ["-p"]))
        results.append(developer)
        for (title, arguments) in [("Xcode", ["-version"]), ("iOS / platform SDKs", ["-showsdks"])] where !isCancelled {
            results.append(developer.status == .available
                ? run(.init(title: title, executable: "/usr/bin/xcodebuild", arguments: arguments))
                : .init(title: title, status: .missing, detail: "Configure Xcode command-line tools in Xcode Settings → Locations."))
        }

        if !isCancelled {
            let configured = environment["JAVA_HOME"].flatMap { $0.isEmpty ? nil : $0 }
            let detected = configured == nil
                ? run(.init(title: "JDK discovery", executable: "/usr/libexec/java_home", arguments: [])) : nil
            let javaHome = configured ?? (detected?.status == .available ? detected?.detail : nil)
            if let javaHome = javaHome {
                results.append(run(.init(title: "Java / JDK", executable: javaHome + "/bin/java", arguments: ["-version"])))
            } else {
                results.append(.init(title: "Java / JDK", status: .missing,
                                     detail: "No JDK found. Install a JDK and set JAVA_HOME.\n" + (detected?.detail ?? "")))
            }
            results.append(androidSDK())
        }
        let redacted = results.map { result in
            DiagnosticResult(title: result.title, status: result.status,
                             detail: result.detail.replacingOccurrences(of: home + "/", with: "~/"))
        }
        return SystemDiagnosticsReport(results: redacted)
    }

    private func androidSDK() -> DiagnosticResult {
        let path = SystemDiagnosticsReport.androidSDKPath(environment: environment, home: home)
        let root = URL(fileURLWithPath: path)
        var directory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &directory), directory.boolValue else {
            return .init(title: "Android SDK / ANDROID_HOME", status: .missing,
                         detail: "\(path)\nInstall the SDK using Android Studio and set ANDROID_HOME.\nANDROID_HOME: \(environment["ANDROID_HOME"] ?? "not set")\nANDROID_SDK_ROOT: \(environment["ANDROID_SDK_ROOT"] ?? "not set")")
        }
        do {
            func versions(_ component: String) throws -> String {
                let folder = root.appendingPathComponent(component)
                guard FileManager.default.fileExists(atPath: folder.path) else { return "none installed" }
                let names = try FileManager.default.contentsOfDirectory(atPath: folder.path).filter { !$0.hasPrefix(".") }
                return names.isEmpty ? "none installed" : names.sorted { $0.localizedStandardCompare($1) == .orderedAscending }.joined(separator: ", ")
            }
            return .init(title: "Android SDK / ANDROID_HOME", status: .available,
                         detail: "\(path)\nANDROID_HOME: \(environment["ANDROID_HOME"] ?? "not set (using fallback)")\nANDROID_SDK_ROOT: \(environment["ANDROID_SDK_ROOT"] ?? "not set")\nPlatforms: \(try versions("platforms"))\nBuild tools: \(try versions("build-tools"))")
        } catch {
            return .init(title: "Android SDK / ANDROID_HOME", status: .failed, detail: "\(path)\n\(error.localizedDescription)")
        }
    }

    /// Internal for focused regression checks; only collects output, never interprets it as code.
    func run(_ check: DiagnosticCheck) -> DiagnosticResult {
        let paths = SystemDiagnosticsReport.searchPaths(environment: environment, home: home)
        let candidates = check.executable.hasPrefix("/") ? [check.executable] : paths.map { $0 + "/" + check.executable }
        guard let executable = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            return .init(title: check.title, status: .missing, detail: "\(check.executable) not found. Install it or add its directory to PATH, then refresh.")
        }
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("rngui-diagnostic-" + UUID().uuidString)
        guard FileManager.default.createFile(atPath: outputURL.path, contents: nil) else {
            return .init(title: check.title, status: .failed, detail: "Cannot create a temporary output file.")
        }
        defer { try? FileManager.default.removeItem(at: outputURL) }
        do {
            let output = try FileHandle(forWritingTo: outputURL)
            defer { try? output.close() }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = check.arguments
            process.environment = environment
            process.currentDirectoryURL = FileManager.default.temporaryDirectory
            process.standardInput = FileHandle.nullDevice
            process.standardOutput = output
            process.standardError = output
            lock.lock()
            if cancelled { lock.unlock(); return .init(title: check.title, status: .failed, detail: "Cancelled") }
            do { try process.run() } catch { lock.unlock(); throw error }
            activeProcess = process
            lock.unlock()
            defer {
                lock.lock()
                activeProcess = nil
                lock.unlock()
            }
            let deadline = Date(timeIntervalSinceNow: timeout)
            while process.isRunning && Date() < deadline && !isCancelled { Thread.sleep(forTimeInterval: 0.03) }
            let timedOut = process.isRunning && !isCancelled
            if process.isRunning {
                process.terminate()
                let grace = Date(timeIntervalSinceNow: 0.2)
                while process.isRunning && Date() < grace { Thread.sleep(forTimeInterval: 0.02) }
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            }
            process.waitUntilExit()
            let reader = try FileHandle(forReadingFrom: outputURL)
            defer { try? reader.close() }
            let data = try reader.read(upToCount: 65536) ?? Data()
            let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            if timedOut { return .init(title: check.title, status: .timedOut, detail: "Command exceeded \(timeout) seconds. Check the tool in Terminal, then refresh.") }
            return .init(title: check.title, status: process.terminationStatus == 0 ? .available : .failed,
                         detail: text.isEmpty ? "Exited with status \(process.terminationStatus)." : text)
        } catch {
            return .init(title: check.title, status: .failed, detail: error.localizedDescription)
        }
    }
}
