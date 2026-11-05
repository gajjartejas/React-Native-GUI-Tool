import Foundation

struct AdbDevice {
    let serial: String
    let model: String
    let state: String
    var label: String { "\(serial) — \(model) [\(state)]" }
}
enum AdbToolPolicy {
    static func devices(_ output: String) -> [AdbDevice] {
        output.components(separatedBy: .newlines).compactMap { line in
            let parts = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            guard parts.count >= 2, !line.hasPrefix("*"), !line.hasPrefix("List of devices"), !parts[0].contains("://") else { return nil }
            let states = ["device", "offline", "unauthorized", "recovery", "sideload", "bootloader", "no"]
            guard states.contains(parts[1]) else { return nil }
            return AdbDevice(serial: parts[0], model: parts.first { $0.hasPrefix("model:") }.map { String($0.dropFirst(6)).replacingOccurrences(of: "_", with: " ") } ?? "Unknown model", state: parts[1])
        }
    }
    static func operations(devices: [AdbDevice]) -> [ToolOperation] {
        let device = ToolField(id: "device", label: "Online device", kind: .choice(devices.filter { $0.state == "device" }.map(\.label)))
        return [
            .init(id: "devices", title: "Refresh devices / emulators"),
            .init(id: "reverse", title: "Reverse TCP port", fields: [device, .init(id: "port", label: "TCP port", initial: "8081")]),
            .init(id: "dev-menu", title: "Open React Native dev menu", fields: [device]),
            .init(id: "reload", title: "Reload app (RR)", fields: [device]),
            .init(id: "install", title: "Install APK", fields: [device, .init(id: "apk", label: "APK file", kind: .openFile)]),
            .init(id: "uninstall", title: "Uninstall package", fields: [device, .init(id: "package", label: "Application ID")]),
            .init(id: "restart", title: "Restart ADB server"),
            .init(id: "tcpip", title: "Enable device TCP/IP", fields: [device, .init(id: "port", label: "TCP port", initial: "5555")]),
            .init(id: "connect", title: "Connect over Wi-Fi", fields: [.init(id: "host", label: "Host / IP:port")]),
            .init(id: "logcat", title: "Stream filtered Logcat", fields: [device, .init(id: "tag", label: "Tag (optional)"), .init(id: "package", label: "App ID (optional)"), .init(id: "level", label: "Minimum log level", kind: .choice(["V", "D", "I", "W", "E", "F"]))])
        ]
    }
    static func selected(_ values: [String: String], devices: [AdbDevice]) throws -> AdbDevice {
        guard let device = devices.first(where: { $0.label == values["device"] && $0.state == "device" }) else { throw ToolInputError(message: "Refresh devices and select an authorized online device.") }
        return device
    }
    static func port(_ values: [String: String]) throws -> String {
        let value = try ToolInput.required(values, "port")
        guard let number = Int(value), (1...65535).contains(number) else { throw ToolInputError(message: "Port must be between 1 and 65535.") }
        return String(number)
    }
    static func applicationID(_ value: String) throws -> String {
        guard value.range(of: #"^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)+$"#, options: .regularExpression) != nil else { throw ToolInputError(message: "Enter a valid Android application ID.") }
        return value
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo, devices: [AdbDevice]) throws -> ToolPlan {
        let directory = project.path
        func command(_ args: [String]) -> ToolCommand { .init(executable: "adb", arguments: args, directory: directory) }
        if operation == "devices" { return .init(commands: [command(["devices", "-l"])]) }
        if operation == "restart" { return .init(commands: [command(["kill-server"]), command(["start-server"])]) }
        if operation == "connect" {
            let host = try ToolInput.required(values, "host")
            guard host.range(of: #"^[A-Za-z0-9.\[\]:_-]+$"#, options: .regularExpression) != nil, !host.hasPrefix("-") else { throw ToolInputError(message: "Enter a host or IP address, optionally followed by :port.") }
            return .init(commands: [command(["connect", host])])
        }
        let device = try selected(values, devices: devices)
        let prefix = ["-s", device.serial]
        let args: [String]
        switch operation {
        case "reverse": let port = try port(values); args = ["reverse", "tcp:" + port, "tcp:" + port]
        case "dev-menu": args = ["shell", "input", "keyevent", "82"]
        case "reload": args = ["shell", "input", "text", "RR"]
        case "install": args = ["install", "-r", try ToolInput.file(values, "apk", extensions: ["apk"])]
        case "uninstall": args = ["uninstall", try applicationID(ToolInput.required(values, "package"))]
        case "tcpip": args = ["tcpip", try port(values)]
        case "logcat":
            let tag = (values["tag"] ?? "").trimmingCharacters(in: .whitespaces)
            guard tag.isEmpty || !tag.hasPrefix("-") && tag.range(of: #"^[A-Za-z0-9_.*$-]+$"#, options: .regularExpression) != nil else { throw ToolInputError(message: "Enter a tag without spaces or option flags.") }
            let level = values["level"] ?? "V"
            guard ["V", "D", "I", "W", "E", "F"].contains(level) else { throw ToolInputError(message: "Select a valid log level.") }
            let filters = tag.isEmpty ? ["*:" + level] : [tag + ":" + level, "*:S"]
            let base = prefix + ["logcat", "-v", "threadtime"]
            let package = (values["package"] ?? "").trimmingCharacters(in: .whitespaces)
            if !package.isEmpty {
                let package = try applicationID(package)
                return .init(commands: [command(prefix + ["shell", "pidof", package])], next: { output in
                    let numericLine = output.components(separatedBy: .newlines).last { line in
                        let tokens = line.split(whereSeparator: { $0.isWhitespace })
                        return !tokens.isEmpty && tokens.allSatisfy { (Int($0) ?? 0) > 0 }
                    }
                    guard let pid = numericLine?.split(whereSeparator: { $0.isWhitespace }).first else { throw ToolInputError(message: "App process not found. Open the app on the selected device, then retry.") }
                    return .init(commands: [command(base + ["--pid", String(pid)] + filters)])
                })
            }
            args = ["logcat", "-v", "threadtime"] + filters
        default: throw ToolInputError(message: "Select an ADB operation.")
        }
        return .init(commands: [command(prefix + args)])
    }
}
