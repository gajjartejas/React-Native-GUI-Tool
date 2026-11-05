import Cocoa

/// Runs real storyboard controllers against temporary data; never drives other apps.
@MainActor
enum UIVerification {
    static func run(issue: String, output: URL) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("rngui-ui-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        var projects: [ProjectInfo] = []
        for name in ["Beta", "Alpha"] {
            let folder = root.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try Data("{\"name\":\"\(name)\",\"dependencies\":{\"react-native\":\"0.75.0\"},\"scripts\":{\"start\":\"printf fixture\"}}".utf8)
                .write(to: folder.appendingPathComponent("package.json"))
            projects.append(ProjectInfo(id: name.lowercased(), path: folder.path))
        }
        let manager = ProjectInfoManager.shared
        manager.append(contentsOf: projects)
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        let window = storyboard.instantiateController(withIdentifier: "MainProjectListWC") as! MainProjectListWC
        window.showWindow(nil)
        let controller = window.contentViewController as! MainProjectListVC
        _ = controller.view
        if issue == "101" {
            controller.projectSearchTextField.stringValue = "Alpha"
            manager.searchBy("Alpha", type: .list)
            controller.sortByNameAction(NSMenuItem())
            precondition(controller.projectInfos.map(\.id) == ["alpha"])
            precondition(ProjectInfo.readArrayFromStorage()?.count == 2)
            controller.projectSearchTextField.stringValue = ""
            manager.clearSearch(type: .list)
            precondition(controller.projectInfos.map(\.id) == ["alpha", "beta"])
        } else {
            fatalError("Unsupported UI verification issue \(issue)")
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        try snapshot(controller.view, to: output)
        print("PASS: storyboard UI verification #\(issue); screenshot \(output.path)")
        window.close()
    }

    static func snapshot(_ view: NSView, to output: URL) throws {
        view.layoutSubtreeIfNeeded()
        view.displayIfNeeded()
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            throw CocoaError(.fileWriteUnknown)
        }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: output)
    }
}
