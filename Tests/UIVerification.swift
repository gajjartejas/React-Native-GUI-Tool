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
