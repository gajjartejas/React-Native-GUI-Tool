import Foundation
import Darwin

/// Each command owns a process group so cancellation also stops child processes.
final class StreamingToolRunner: ToolRunning {
    private let lock = NSLock()
    private var cancelled = false
    private var group: pid_t = 0
    private let baseEnvironment: [String: String]
    init(environment: [String: String] = ProcessInfo.processInfo.environment) { baseEnvironment = environment }

    func cancel() {
        lock.lock(); cancelled = true; let pid = group; lock.unlock()
        if pid > 0 { kill(-pid, SIGTERM) }
    }
    private var isCancelled: Bool { lock.lock(); defer { lock.unlock() }; return cancelled }
    func run(_ plan: ToolPlan, onOutput: @escaping (Data) -> Void, completion: @escaping (ToolRunResult) -> Void) {
        DispatchQueue.global(qos: .utility).async { [self] in
            var collected = Data()
            var exitCode: Int32 = 0
            do {
                for command in plan.commands {
                    if isCancelled { break }
                    let heading = Data(("\n$ " + command.display + "\n").utf8)
                    DispatchQueue.main.async { onOutput(heading) }
                    exitCode = try execute(command) { data in
                        collected.append(data)
                        if collected.count > 1_000_000 { collected.removeFirst(collected.count - 1_000_000) }
                        DispatchQueue.main.async { onOutput(data) }
                    }
                    if exitCode != 0 { break }
                }
            } catch {
                exitCode = -1
                let data = Data((error.localizedDescription + "\n").utf8)
                collected.append(data); DispatchQueue.main.async { onOutput(data) }
            }
            let result = ToolRunResult(exitCode: exitCode, cancelled: isCancelled, output: String(decoding: collected, as: UTF8.self))
            DispatchQueue.main.async { completion(result) }
        }
    }
    private func executable(_ name: String, environment: [String: String]) throws -> String {
        let home = NSHomeDirectory()
        var paths = SystemDiagnosticsReport.searchPaths(environment: environment, home: home)
        paths.insert(SystemDiagnosticsReport.androidSDKPath(environment: environment, home: home) + "/platform-tools", at: 0)
        if ["java", "keytool"].contains(name) {
            let java = environment["JAVA_HOME"] ?? SystemDiagnosticsScanner(environment: environment).run(.init(title: "JDK", executable: "/usr/libexec/java_home", arguments: [])).detail
            if FileManager.default.isExecutableFile(atPath: java + "/bin/" + name) { return java + "/bin/" + name }
            throw ToolInputError(message: "No JDK found. Install a JDK and set JAVA_HOME, then retry.")
        }
        let candidates = name.hasPrefix("/") ? [name] : paths.map { $0 + "/" + name }
        guard let path = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            throw ToolInputError(message: "\(name) not found. Install it or add its directory to PATH, then retry.")
        }
        return path
    }
    private func execute(_ command: ToolCommand, output: (Data) -> Void) throws -> Int32 {
        var environment = baseEnvironment.merging(command.environment) { _, new in new }
        environment["PATH"] = SystemDiagnosticsReport.searchPaths(environment: environment, home: NSHomeDirectory()).joined(separator: ":")
        let executable = try executable(command.executable, environment: environment)
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("rngui-tool-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: temp) }
        var arguments = command.arguments
        for (token, secret) in command.secretFiles {
            let url = temp.appendingPathComponent(UUID().uuidString)
            FileManager.default.createFile(atPath: url.path, contents: Data(secret.utf8), attributes: [.posixPermissions: 0o600])
            arguments = arguments.map { $0.replacingOccurrences(of: token, with: url.path) }
        }
        let log = temp.appendingPathComponent("output")
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        posix_spawn_file_actions_init(&actions); posix_spawnattr_init(&attributes)
        defer { posix_spawn_file_actions_destroy(&actions); posix_spawnattr_destroy(&attributes) }
        if #available(macOS 26, *) { posix_spawn_file_actions_addchdir(&actions, command.directory) }
        else { posix_spawn_file_actions_addchdir_np(&actions, command.directory) }
        posix_spawn_file_actions_addopen(&actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0)
        posix_spawn_file_actions_addopen(&actions, STDOUT_FILENO, log.path, O_WRONLY | O_CREAT | O_TRUNC, 0o600)
        posix_spawn_file_actions_adddup2(&actions, STDOUT_FILENO, STDERR_FILENO)
        posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_SETPGROUP))
        posix_spawnattr_setpgroup(&attributes, 0)
        let argv = ([executable] + arguments).map { strdup($0) } + [nil]
        let envp = environment.map { strdup($0.key + "=" + $0.value) } + [nil]
        defer { for pointer in argv + envp { free(pointer) } }
        var pid: pid_t = 0
        lock.lock()
        if cancelled { lock.unlock(); return -1 }
        let error = argv.withUnsafeBufferPointer { a in envp.withUnsafeBufferPointer { e in
            posix_spawn(&pid, executable, &actions, &attributes, a.baseAddress!, e.baseAddress!)
        } }
        if error == 0 { group = pid }
        lock.unlock()
        guard error == 0 else { throw ToolInputError(message: "Cannot launch \(command.executable): \(String(cString: strerror(error)))") }
        var reaped = false
        defer {
            if !reaped { kill(-pid, SIGKILL); var status: Int32 = 0; waitpid(pid, &status, 0) }
            lock.lock(); group = 0; lock.unlock()
        }
        let reader = try FileHandle(forReadingFrom: log)
        defer { try? reader.close() }
        var status: Int32 = 0
        var cancelDeadline: Date?
        while true {
            if let data = try reader.read(upToCount: 32768), !data.isEmpty { output(data) }
            if isCancelled {
                if cancelDeadline == nil { kill(-pid, SIGTERM); cancelDeadline = Date(timeIntervalSinceNow: 0.3) }
                if Date() >= cancelDeadline! { kill(-pid, SIGKILL) }
            }
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid || waited == -1 {
                reaped = true
                if isCancelled { kill(-pid, SIGKILL) }
                break
            }
            Thread.sleep(forTimeInterval: 0.03)
        }
        while let data = try reader.read(upToCount: 32768), !data.isEmpty { output(data) }
        return (status & 0x7f) == 0 ? (status >> 8) & 0xff : 128 + (status & 0x7f)
    }
}
