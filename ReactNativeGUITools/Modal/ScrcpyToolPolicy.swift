import Foundation

enum ScrcpyToolPolicy {
    static func operations(devices: [AdbDevice]) -> [ToolOperation] {
        [
            .init(id: "version", title: "Check scrcpy installation / version"),
            .init(id: "devices", title: "Refresh connected devices"),
            .init(id: "start", title: "Start Mirroring", fields: [
                .init(id: "device", label: "Online device", kind: .choice(devices.filter { $0.state == "device" }.map(\.label))),
                .init(id: "awake", label: "Stay awake", kind: .toggle),
                .init(id: "screen-off", label: "Turn device screen off", kind: .toggle),
                .init(id: "touches", label: "Show physical touches", kind: .toggle),
                .init(id: "top", label: "Always on top", kind: .toggle),
                .init(id: "size", label: "Max resolution (0 = unlimited)", initial: "1920"),
                .init(id: "bitrate", label: "Video bit rate", initial: "8M"),
                .init(id: "record", label: "Record to file (optional)", kind: .saveFile)
            ])
        ]
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo, devices: [AdbDevice]) throws -> ToolPlan {
        if operation == "devices" { return try AdbToolPolicy.plan(operation: "devices", values: values, project: project, devices: devices) }
        if operation == "version" { return .init(commands: [.init(executable: "scrcpy", arguments: ["--version"], directory: project.path)]) }
        guard operation == "start" else { throw ToolInputError(message: "Select a scrcpy operation.") }
        let device = try AdbToolPolicy.selected(values, devices: devices)
        let size = try ToolInput.required(values, "size")
        guard let number = Int(size), (0...16384).contains(number) else { throw ToolInputError(message: "Resolution must be between 0 and 16384.") }
        let bitrate = try ToolInput.required(values, "bitrate")
        guard bitrate.range(of: #"^[1-9][0-9]*[KMGkmg]?$"#, options: .regularExpression) != nil else { throw ToolInputError(message: "Enter a bit rate such as 8M or 8000000.") }
        var args = ["--serial", device.serial, "--max-size", String(number), "--video-bit-rate", bitrate]
        for (key, flag) in [("awake", "--stay-awake"), ("screen-off", "--turn-screen-off"), ("touches", "--show-touches"), ("top", "--always-on-top")] where values[key] == "true" { args.append(flag) }
        if !(values["record"] ?? "").isEmpty { args += ["--record", try ToolInput.file(values, "record", extensions: ["mp4", "mkv"])] }
        return .init(commands: [.init(executable: "scrcpy", arguments: args, directory: project.path)])
    }
}
