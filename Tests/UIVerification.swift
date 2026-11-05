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
        if issue == "67" {
            let status = ProjectListStatusBarMenuController(projectInfos: projects)
            status.searchView.onSearch?("Alpha")
            precondition(status.projectInfos.map(\.id) == ["alpha"])
            precondition(manager.get(type: .list).count == 2)
            precondition(status.statusBarMenu.items.filter { $0.submenu != nil }.map(\.title) == ["Alpha"])
            status.searchView.onSearch?("no matches")
            precondition(status.statusBarMenu.items.contains { $0.title == "No matching projects" })
            status.searchView.onSearch?("")
            precondition(status.projectInfos.count == 2 && ProjectInfo.readArrayFromStorage()?.count == 2)
            status.searchView.searchField.stringValue = "Alpha"
            status.searchView.onSearch?("Alpha")
            try snapshotReport(title: "Status menu search — #67", lines: ["Query: Alpha", "Visible project: " + status.projectInfos[0].name!, "PASS: main list and saved registrations remain unchanged", "PASS: no-match message and clearing search"], to: output)
            NSStatusBar.system.removeStatusItem(status.statusBarItem)
            return
        } else if issue == "101" {
            controller.projectSearchTextField.stringValue = "Alpha"
            manager.searchBy("Alpha", type: .list)
            controller.sortByNameAction(NSMenuItem())
            precondition(controller.projectInfos.map(\.id) == ["alpha"])
            precondition(ProjectInfo.readArrayFromStorage()?.count == 2)
            controller.projectSearchTextField.stringValue = ""
            manager.clearSearch(type: .list)
            precondition(controller.projectInfos.map(\.id) == ["alpha", "beta"])
        } else if issue == "104" {
            let editor = storyboard.instantiateController(withIdentifier: "AddCustomActionVC") as! AddCustomActionVC
            editor.projectInfo = projects[0]
            _ = editor.view
            editor.menuNameTextField.stringValue = "Quoted command"
            editor.scriptTextField.stringValue = "printf \"hello\\n\""
            let command = projects[0].terminalCommand(.custom(editor.scriptTextField.stringValue))
            let result = try fixtureShell(command)
            precondition(result == "hello\n")
            var error: NSDictionary?
            precondition(NSAppleScript(source: terminalAppleScriptSource(command: command))!.compileAndReturnError(&error))
            let editorWindow = NSWindow(contentViewController: editor)
            editorWindow.makeKeyAndOrderFront(nil)
            try snapshot(editor.view, to: output)
            print("PASS: custom command executed and Terminal AppleScript compiled; screenshot \(output.path)")
            return
        } else if issue == "87" {
            let settings = storyboard.instantiateController(withIdentifier: "MainSettingsVC") as! MainSettingsVC
            _ = settings.view
            let editor = PathVersion(path: "/Fixture/Editor.app", version: "1", bundleId: .vscode)
            let xcode = PathVersion(path: "/Fixture/Xcode.app", version: "16", bundleId: .xcode)
            let android = PathVersion(path: "/Fixture/Android Studio.app", version: "2025", bundleId: .androidStudio)
            func select(_ popup: NSPopUpButton, _ item: PathVersion) {
                popup.removeAllItems()
                popup.addItem(withTitle: item.description)
                popup.lastItem?.representedObject = item
            }
            select(settings.codeEditorPathPopupMenu, editor)
            settings.codeEditorPopUpButtonSelectionChanged(settings.codeEditorPathPopupMenu)
            settings.codeEditorPathPopupMenu.removeAllItems()
            select(settings.xcodePathPopupMenu, xcode)
            settings.xcodePopUpButtonSelectionChanged(settings.xcodePathPopupMenu)
            select(settings.androidStudioPopupMenu, android)
            settings.androidStudioPopUpButtonSelectionChanged(settings.androidStudioPopupMenu)
            let saved = MainSettings.readFromStorage()!
            precondition(saved.defaultCodeEditor?.path == editor.path)
            precondition(saved.defaultXcodePath?.path == xcode.path && settings.xcodePathLabel.stringValue == xcode.path)
            precondition(saved.defaultAndroidStudio?.path == android.path && settings.androidStudioPathLabel.stringValue == android.path)
            settings.xcodePathPopupMenu.removeAllItems()
            settings.xcodePopUpButtonSelectionChanged(settings.xcodePathPopupMenu)
            precondition(MainSettings.readFromStorage()?.defaultXcodePath?.path == xcode.path)
            select(settings.xcodePathPopupMenu, xcode)
            settings.tabView.selectTabViewItem(withIdentifier: "Locations")
            let settingsWindow = NSWindow(contentViewController: settings)
            settingsWindow.makeKeyAndOrderFront(nil)
            try snapshot(settings.view, to: output)
            print("PASS: settings select and persist each tool independently; empty selection is safe; screenshot \(output.path)")
            return
        } else if issue == "88" {
            var paths: [String] = []
            let menuController = ProjectListMenuController(trashFolder: { paths.append($0) })
            let menu = menuController.createMenuFrom(projectInfos: projects, row: 0)
            let android = menu.items.first { $0.title == "Clean" }!.submenu!.items.first { $0.title == "Clean Android" }!.submenu!
            let appBuild = android.items.first { $0.title == "app/build" }!
            precondition(appBuild.action == #selector(ProjectListMenuController.cleanAndroidAppBuildFolder(_:)))
            precondition((appBuild.target as? ProjectListMenuController) === menuController)
            _ = menuController.perform(appBuild.action!, with: appBuild)
            precondition(paths == [projects[0].path + "/android/app/build"])
            menuController.cleanAndroidBuildFolder(NSMenuItem())
            precondition(paths.last == projects[0].path + "/android/build")
            try snapshotReport(title: "Android cleanup routing — #88", lines: [
                "PASS: app/build menu -> cleanAndroidAppBuildFolder",
                "Target: " + paths[0],
                "PASS: build menu remains distinct",
                "Target: " + paths[1],
                "Trash adapter replaced by a recording spy. No folders deleted."
            ], to: output)
            print("PASS: actual menu selectors dispatch distinct Android cleanup targets; screenshot \(output.path)")
            return
        } else if issue == "102" {
            for name in ["Gamma", "Delta", "Epsilon"] {
                try FileManager.default.createDirectory(at: root.appendingPathComponent(name), withIntermediateDirectories: true)
                try Data("{\"name\":\"\(name)\",\"dependencies\":{\"react-native\":\"0.75.0\"}}".utf8)
                    .write(to: root.appendingPathComponent(name).appendingPathComponent("package.json"))
            }
            let gamma = ProjectInfo(id: "gamma", path: root.appendingPathComponent("Gamma").path)
            gamma.name = "Gamma"
            let delta = ProjectInfo(id: "delta", path: root.appendingPathComponent("Delta").path)
            delta.name = "Delta"
            var prompts = 0
            precondition(controller.importProjects([gamma, delta, gamma], at: 0, confirmDuplicate: { _ in prompts += 1; return false }))
            precondition(prompts == 0 && manager.get(type: .all).map(\.id) == ["gamma", "delta", "beta", "alpha"])
            let duplicate = ProjectInfo(id: "duplicate", path: projects[0].path)
            let epsilon = ProjectInfo(id: "epsilon", path: root.appendingPathComponent("Epsilon").path)
            epsilon.name = "Epsilon"
            precondition(controller.importProjects([duplicate, epsilon], at: 0, confirmDuplicate: { _ in
                prompts += 1
                precondition(manager.get(type: .all).count == 4, "Mutated before duplicate validation finished")
                return false
            }))
            precondition(prompts == 1 && manager.get(type: .all).first?.id == "epsilon")
            precondition(controller.importProjects([duplicate], at: 0, confirmDuplicate: { _ in true }))
            precondition(manager.get(type: .all).filter { $0.path == duplicate.path }.count == 2)
            precondition(ProjectInfo.readArrayFromStorage()?.count == 6)
            print("PASS: fresh batch, repeated input, cancel/accept existing duplicate, and atomic persistence")
        } else if issue == "103" {
            projects[0].appendCustomScript(try .validated(name: "Beta action", script: "printf beta"))
            projects[1].appendCustomScript(try .validated(name: "Alpha action", script: "printf alpha"))
            controller.projectListMenu(didSelectOpenMenuItem: NSMenuItem(), at: 0)
            let beta = NSWindowController.getAllControllers().compactMap { $0 as? ToolsOutlineWC }.first!
            precondition(beta.projectInfo?.id == "beta")
            controller.projectSearchTextField.stringValue = "Alpha"
            manager.searchBy("Alpha", type: .list)
            controller.projectListMenu(didSelectOpenMenuItem: NSMenuItem(), at: 0)
            let windows = NSWindowController.getAllControllers().compactMap { $0 as? ToolsOutlineWC }
            precondition(windows.count == 2)
            let alpha = windows.first { $0.projectInfo?.id == "alpha" }!
            controller.projectListMenu.setClickedRow(0)
            controller.projectListMenu.customActionsEdit(NSMenuItem())
            let split = alpha.contentViewController as! NSSplitViewController
            let tabs = split.children[1] as! ProjectTabViewController
            precondition(tabs.projectInfo?.id == "alpha" && tabs.selectedTabViewItemIndex == 12)
            let actions = tabs.children[12] as! CustomActionsVC
            precondition(actions.projectInfo?.customMenuScripts?.first?.name == "Alpha action")
            let status = ProjectListStatusBarMenuController(projectInfos: manager.get(type: .menu))
            status.projectListMenu(didSelectOpenMenuItem: NSMenuItem(), at: 0)
            precondition(NSWindowController.getAllControllers().compactMap { $0 as? ToolsOutlineWC }.count == 2)
            NSStatusBar.system.removeStatusItem(status.statusBarItem)
            manager.clearSearch(type: .list)
            manager.sorted(by: .name)
            controller.projectListMenu(didSelectOpenMenuItem: NSMenuItem(), at: 1)
            precondition(ToolsOutlineWC.show(project: projects[0]) === beta)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            try snapshot(split.view, to: output)
            print("PASS: filtered row collision creates distinct windows; status/menu/sort reuse stable IDs; screenshot \(output.path)")
            return
        } else if issue == "105" {
            var commands: [String] = []
            let menuController = ProjectListMenuController(runTerminal: { path, command in
                precondition(path == projects[0].path)
                commands.append(command)
            })
            let menu = menuController.createMenuFrom(projectInfos: projects, row: 0)
            let npm = menu.items.first { $0.title == "NPM" }!.submenu!
            let reset = npm.items.first { $0.action == #selector(ProjectListMenuController.npmStartResetCache(_:)) }!
            _ = menuController.perform(reset.action!, with: reset)
            precondition(commands.count == 1)
            let result = try fixtureShell("npm() { printf '%s\\n' \"$@\"; }; " + commands[0])
            precondition(result == "start\n--\n--reset-cache\n")
            try snapshotReport(title: "NPM reset-cache menu — #105", lines: [
                "PASS: NPM / " + reset.title,
                "Command: " + commands[0],
                "Captured npm arguments: " + result.replacingOccurrences(of: "\n", with: " | "),
                "Terminal adapter recorded the action. Metro was not started."
            ], to: output)
            print("PASS: actual reset-cache menu invokes npm with start -- --reset-cache; screenshot \(output.path)")
            return
        } else if issue == "106" {
            let external = root.appendingPathComponent("Beta-other/task's script.sh")
            try FileManager.default.createDirectory(at: external.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data("#!/bin/sh\nprintf external".utf8).write(to: external)
            let editor = storyboard.instantiateController(withIdentifier: "AddCustomActionVC") as! AddCustomActionVC
            editor.projectInfo = projects[0]
            _ = editor.view
            editor.menuNameTextField.stringValue = "External sibling script"
            editor.scriptTextField.stringValue = projects[0].customScriptPath(for: external.path)
            precondition(editor.scriptTextField.stringValue == external.path)
            let action = try ProjectInfo.CustomMenuScript.validated(name: editor.menuNameTextField.stringValue, script: editor.scriptTextField.stringValue)
            precondition(action.isFileScript)
            projects[0].appendCustomScript(action)
            manager.update(with: projects[0])
            precondition(ProjectInfo.readArrayFromStorage()?.first?.customMenuScripts?.first?.script == external.path)
            let command = projects[0].terminalCommand(.customFile(action.script))
            precondition(command.hasSuffix(shellQuoted(external.path)))
            let editorWindow = NSWindow(contentViewController: editor)
            editorWindow.makeKeyAndOrderFront(nil)
            try snapshot(editor.view, to: output)
            print("PASS: sibling script retains its absolute path through editor, persistence, and command construction; screenshot \(output.path)")
            return
        } else if issue == "108" {
            let parsed = readPackageJSON(atPath: projects[0].path)
            precondition(parsed.name == "Beta" && parsed.version == "0.75.0" && parsed.scriptsArray?.count == 1)
            try snapshotReport(title: "Package manifest verification — #108", lines: [
                "PASS: valid package.json parsed successfully",
                "Name: " + (parsed.name ?? "missing"),
                "React Native: " + (parsed.version ?? "missing"),
                "Scripts: " + (parsed.scriptsArray?.map(\.name).joined(separator: ", ") ?? "missing"),
                "Runner checks captured stdout/stderr for the legacy false diagnostic."
            ], to: output)
            print("PASS: valid manifest metadata rendered; stdout/stderr captured by runner; screenshot \(output.path)")
            return
        } else if issue == "90" {
            let system = storyboard.instantiateController(withIdentifier: "SystemInfoVC") as! SystemInfoVC
            let first = ControlledDiagnosticsScanner()
            let second = ControlledDiagnosticsScanner()
            var scanners: [SystemDiagnosticsScanning] = [first, second]
            system.makeScanner = { scanners.removeFirst() }
            var copied = ""
            system.writeReportToPasteboard = { copied = $0 }
            let systemView = system.view as! SystemInfoView
            precondition(!systemView.copyButton.isEnabled)
            systemView.refreshButton.performClick(nil)
            precondition(!systemView.refreshButton.isEnabled && !systemView.copyButton.isEnabled)
            system.refreshDiagnostics()
            precondition(first.cancellations == 1)
            let fixture = SystemDiagnosticsReport(results: [
                .init(title: "macOS", status: .available, detail: "macOS fixture"),
                .init(title: "CPU architecture", status: .available, detail: "Apple Silicon (arm64)"),
                .init(title: "Node.js", status: .available, detail: "v22.11.0"),
                .init(title: "npm", status: .available, detail: "10.9.0"),
                .init(title: "Yarn", status: .missing, detail: "yarn not found. Install it or add its directory to PATH, then refresh."),
                .init(title: "Watchman", status: .available, detail: "2026.11.01"),
                .init(title: "Watchman service", status: .failed, detail: "Service is not running. Diagnostics does not start it."),
                .init(title: "Command-line tools", status: .available, detail: "/Applications/Xcode.app/Contents/Developer"),
                .init(title: "Xcode", status: .available, detail: "Xcode fixture"),
                .init(title: "iOS / platform SDKs", status: .available, detail: "iOS fixture SDK"),
                .init(title: "CocoaPods", status: .available, detail: "1.16.2"),
                .init(title: "Java / JDK", status: .available, detail: "OpenJDK 17 fixture"),
                .init(title: "Android SDK / ANDROID_HOME", status: .available, detail: "~/Library/Android/sdk\nPlatforms: android-35\nBuild tools: 35.0.0")
            ])
            first.finish(SystemDiagnosticsReport(results: []))
            precondition(!systemView.refreshButton.isEnabled, "Stale completion replaced active scan")
            second.finish(fixture)
            precondition(systemView.reportTextView.string == fixture.text && systemView.copyButton.isEnabled && systemView.refreshButton.isEnabled)
            systemView.copyButton.performClick(nil)
            precondition(copied == fixture.text)
            let systemWindow = NSWindow(contentViewController: system)
            systemWindow.setContentSize(NSSize(width: 760, height: 900))
            systemWindow.makeKeyAndOrderFront(nil)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            precondition(!systemView.hasAmbiguousLayout)
            try snapshot(systemView, to: output)
            systemWindow.setContentSize(NSSize(width: 450, height: 500))
            systemView.layoutSubtreeIfNeeded()
            precondition(!systemView.hasAmbiguousLayout)
            let third = ControlledDiagnosticsScanner()
            system.makeScanner = { third }
            systemView.refreshButton.performClick(nil)
            system.viewDidDisappear()
            precondition(third.cancellations == 1 && systemView.refreshButton.isEnabled)
            third.finish(SystemDiagnosticsReport(results: []))
            precondition(systemView.reportTextView.string == fixture.text, "Hidden screen accepted cancelled output")
            if let home = ProcessInfo.processInfo.environment["RNGUI_LIVE_DIAGNOSTICS_HOME"] {
                _ = try SystemDiagnosticsTests.liveScan(home: home)
            }
            print("PASS: System Info storyboard, Refresh/Copy actions, scan state, stale callback, and resizing; screenshot \(output.path)")
            return
        } else {
            fatalError("Unsupported UI verification issue \(issue)")
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        try snapshot(controller.view, to: output)
        print("PASS: storyboard UI verification #\(issue); screenshot \(output.path)")
        window.close()
    }

    static func snapshotReport(title: String, lines: [String], to output: URL) throws {
        let text = NSTextView(frame: NSRect(x: 0, y: 0, width: 1000, height: 320))
        text.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        text.textContainerInset = NSSize(width: 20, height: 20)
        text.string = title + "\n\n" + lines.joined(separator: "\n\n")
        text.textColor = .labelColor
        text.backgroundColor = .textBackgroundColor
        let reportWindow = NSWindow(contentRect: text.frame, styleMask: [.titled], backing: .buffered, defer: false)
        reportWindow.contentView = text
        reportWindow.makeKeyAndOrderFront(nil)
        try snapshot(text, to: output)
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

/// Executes only explicit, test-owned shell snippets in temporary fixtures.
func fixtureShell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", command]
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    let output = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { throw CocoaError(.executableRuntimeMismatch) }
    return String(decoding: output, as: UTF8.self)
}
