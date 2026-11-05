import Cocoa

@MainActor
enum FeatureUIVerification {
    static func wait(_ predicate: () -> Bool) {
        let end = Date(timeIntervalSinceNow: 5)
        while !predicate() && Date() < end { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.02)) }
        precondition(predicate(), "UI operation did not complete")
    }
    static func run(issue: String, project: ProjectInfo, root: URL, storyboard: NSStoryboard, output: URL) throws {
        if issue == "89" {
            let folder = URL(fileURLWithPath: project.path)
            try Data(#"{"name":"Fixture","version":"1.2.3","private":true,"dependencies":{"react-native":"0.75.0","react":"18.3"},"devDependencies":{"jest":"29"}}"#.utf8).write(to: folder.appendingPathComponent("package.json"))
            let android = folder.appendingPathComponent("android/app")
            try FileManager.default.createDirectory(at: android, withIntermediateDirectories: true)
            try Data("applicationId = \"com.fixture.app\"".utf8).write(to: android.appendingPathComponent("build.gradle.kts"))
            let ios = folder.appendingPathComponent("ios/Fixture.xcodeproj")
            try FileManager.default.createDirectory(at: ios, withIntermediateDirectories: true)
            try Data("PRODUCT_BUNDLE_IDENTIFIER = com.fixture.ios;".utf8).write(to: ios.appendingPathComponent("project.pbxproj"))
            let metadata = try ProjectMetadata.read(path: project.path, home: root.path)
            precondition(metadata.summary.contains("com.fixture.app") && metadata.summary.contains("com.fixture.ios") && metadata.summary.contains("~/Beta"))
            precondition(metadata.filtered("jest").count == 1 && metadata.filtered("no-match").isEmpty)
            let vc = storyboard.instantiateController(withIdentifier: "ProjectInfoVC") as! ProjectInfoVC
            vc.projectInfo = project
            let panel = vc.view as! ProjectInfoPanel
            wait { panel.status.stringValue.contains("3 dependencies") }
            panel.search.stringValue = "react-native"; panel.onSearch?("react-native")
            precondition(panel.table.numberOfRows == 1)
            var actions: [ProjectShortcut] = []
            vc.performShortcut = { action, selected in precondition(selected.id == project.id); actions.append(action) }
            for action in ProjectShortcut.allCases where action != .refresh { panel.onShortcut?(action) }
            precondition(actions.count == 5)
            let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 650)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(panel, to: output)
            print("PASS: Project Info metadata, native identifiers, search and five shortcuts")
        } else if issue == "91" {
            try ToolRunnerTests.run(root: root)
            let vc = storyboard.instantiateController(withIdentifier: "NpmVC") as! NpmVC
            vc.projectInfo = project
            let runner = RecordingToolRunner(); vc.makeRunner = { runner }
            _ = vc.view; wait { vc.panel.runButton.isEnabled }
            vc.selectOperation("add"); vc.panel.setValue("@fixture/pkg@^1", for: "package"); vc.panel.setValue("true", for: "dev")
            vc.panel.runButton.performClick(nil)
            precondition(runner.plans.last?.commands[0].arguments == ["install", "@fixture/pkg@^1", "--save-dev"])
            precondition(runner.plans.last?.commands[0].directory == project.path && vc.panel.console.string.contains("fixture output"))
            vc.panel.cancelButton.performClick(nil); precondition(runner.cancelled && vc.panel.status.stringValue == "Cancelled")
            vc.selectOperation("run"); vc.panel.setValue("start", for: "script"); vc.panel.setValue(#"["--port","9000"]"#, for: "arguments")
            vc.runOperation(); precondition(runner.plans.last?.commands[0].arguments == ["run", "start", "--", "--port", "9000"]); runner.finish()
            for op in ["install", "outdated", "audit", "audit-fix", "cache-clean", "cache-verify"] {
                let plan = try PackageToolPolicy.plan(operation: op, values: ["ci":"true","legacy":"true"], project: project)
                precondition(plan.commands[0].executable == "npm")
            }
            let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 650)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            print("PASS: NPM add/dev, script arguments, cancellation, console and all operation plans")
        } else if issue == "92" {
            let classic = try PackageToolPolicy.yarnPlan(operation: "install", values: ["frozen":"true"], project: project, major: 1)
            let modern = try PackageToolPolicy.yarnPlan(operation: "install", values: ["frozen":"true"], project: project, major: 4)
            precondition(classic.commands[0].arguments == ["install", "--frozen-lockfile"] && modern.commands[0].arguments == ["install", "--immutable"])
            precondition(PackageToolPolicy.yarnMajor("4.6.0\n") == 4 && PackageToolPolicy.yarnMajor("not installed") == nil)
            let vc = storyboard.instantiateController(withIdentifier: "YarnVC") as! YarnVC
            vc.projectInfo = project; let runner = RecordingToolRunner(); vc.makeRunner = { runner }
            _ = vc.view; wait { vc.panel.runButton.isEnabled }
            vc.runOperation(); precondition(runner.plans.last?.commands[0].arguments == ["--version"])
            runner.finish(output: "4.6.0"); wait { vc.panel.status.stringValue.contains("Modern") }
            vc.selectOperation("upgrade"); vc.panel.setValue("react-native@latest", for: "package"); vc.runOperation()
            precondition(runner.plans.last?.commands[0].arguments == ["up", "react-native@latest"])
            vc.panel.cancelButton.performClick(nil); precondition(runner.cancelled)
            vc.selectOperation("install"); vc.panel.setValue("true", for: "frozen"); vc.runOperation()
            precondition(runner.plans.last?.commands[0].arguments == ["install", "--immutable"]); runner.finish()
            wait { vc.panel.runButton.isEnabled }
            let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 650)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            print("PASS: Yarn version detection, Classic/Modern lock flags, upgrade and cancellation")
        } else if issue == "66" {
            let service = FixtureLoginService()
            let vc = storyboard.instantiateController(withIdentifier: "MainSettingsVC") as! MainSettingsVC
            vc.loginService = service
            _ = vc.view; wait { vc.loginView.toggle.isEnabled }
            precondition(vc.loginView.toggle.state == .off)
            vc.loginView.onChange?(true); wait { vc.loginView.toggle.isEnabled }
            precondition(service.changes == [true] && vc.loginView.toggle.state == .on)
            service.state = .approvalRequired; vc.updateLogin(enabled: nil); wait { vc.loginView.toggle.isEnabled }
            precondition(vc.loginView.toggle.state == .mixed && vc.loginView.message.stringValue.contains("Approval"))
            service.failure = true; vc.loginView.onChange?(false); wait { vc.loginView.toggle.isEnabled }
            precondition(vc.loginView.message.stringValue.contains("Unable to change"))
            service.failure = false; vc.loginView.onChange?(false); wait { vc.loginView.toggle.isEnabled }
            precondition(vc.loginView.toggle.state == .off)
            vc.tabView.selectTabViewItem(withIdentifier: "General")
            let window = NSWindow(contentViewController: vc); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            print("PASS: login-item enable/disable, approval-required and error states; no real registration changed")
        } else if issue == "94" {
            try ToolRunnerTests.run(root: root)
            let listing = "List of devices attached\nserial1 device model:Pixel_8 transport_id:1\nserial2 unauthorized model:Other\n"
            let devices = AdbToolPolicy.devices(listing); precondition(devices.count == 2 && devices[0].model == "Pixel 8")
            let values = ["device":devices[0].label, "port":"8081", "package":"com.fixture.app", "level":"I", "tag":"ReactNative"]
            let reverse = try AdbToolPolicy.plan(operation: "reverse", values: values, project: project, devices: devices)
            precondition(reverse.commands[0].arguments == ["-s", "serial1", "reverse", "tcp:8081", "tcp:8081"])
            let logs = try AdbToolPolicy.plan(operation: "logcat", values: values, project: project, devices: devices)
            let stream = try logs.next!("1234\n")
            precondition(stream.commands[0].arguments.contains("--pid") && stream.commands[0].arguments.contains("1234"))
            do { _ = try AdbToolPolicy.selected(["device":devices[1].label], devices: devices); preconditionFailure("Unauthorized device accepted") } catch {}
            let vc = storyboard.instantiateController(withIdentifier: "AdbVC") as! AdbVC
            vc.projectInfo = project; let runner = RecordingToolRunner(); vc.makeRunner = { runner }; _ = vc.view
            wait { vc.panel.runButton.isEnabled }; vc.runOperation(); runner.finish(output: listing)
            wait { vc.panel.resultTable.numberOfRows == 2 && vc.panel.runButton.isEnabled }
            vc.selectOperation("dev-menu"); vc.runOperation()
            precondition(runner.plans.last?.commands[0].arguments == ["-s", "serial1", "shell", "input", "keyevent", "82"])
            runner.finish(); let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 700)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            print("PASS: device parsing/table, online selection, reverse, dev menu and package-PID Logcat")
        } else if issue == "93" {
            let folder = URL(fileURLWithPath: project.path)
            try FileManager.default.createDirectory(at: folder.appendingPathComponent("ios/Fixture.xcworkspace"), withIntermediateDirectories: true)
            let android = try BuildToolPolicy.plan(operation: "android-debug", values: ["flavor":"demo"], project: project)
            precondition(android.commands[0].arguments == ["assembleDemoDebug"] && android.commands[0].directory.hasSuffix("/android"))
            let simulator = try BuildToolPolicy.plan(operation: "ios-simulator", values: ["container":folder.path + "/ios/Fixture.xcworkspace", "scheme":"Fixture", "output":folder.path + "/build/ios"], project: project)
            precondition(simulator.commands[0].arguments.contains("CODE_SIGNING_ALLOWED=NO") && simulator.commands[0].arguments.contains("generic/platform=iOS Simulator"))
            let export = try BuildToolPolicy.plan(operation: "ios-export", values: ["archive":folder.path + "/Archive.xcarchive", "plist":folder.path + "/Export.plist", "output":folder.path + "/ipa"], project: project)
            precondition(export.commands[0].arguments.contains("-exportOptionsPlist"))
            let vc = storyboard.instantiateController(withIdentifier: "GenerateBuildVC") as! GenerateBuildVC
            vc.projectInfo = project; let runner = RecordingToolRunner(); vc.makeRunner = { runner }
            var revealed = ""; vc.openOutputDirectory = { revealed = $0; return true }
            _ = vc.view; wait { vc.panel.runButton.isEnabled }
            vc.selectOperation("android-release"); vc.panel.setValue("true", for: "reveal"); vc.runOperation()
            precondition(runner.plans.last?.commands[0].arguments == ["assembleRelease"]); runner.finish(output: "BUILD SUCCESSFUL")
            precondition(revealed.hasSuffix("/android/app/build/outputs/apk"))
            let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 650)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            print("PASS: Android flavors, iOS simulator/export arguments, build console and output-folder route")
        } else if issue == "95" {
            let vc = storyboard.instantiateController(withIdentifier: "ScrcpyVC") as! ScrcpyVC
            vc.projectInfo = project; let runner = RecordingToolRunner(); vc.makeRunner = { runner }; _ = vc.view
            wait { vc.panel.runButton.isEnabled }; vc.selectOperation("devices"); vc.runOperation()
            runner.finish(output: "List of devices attached\nserial1 device model:Pixel_8\n"); wait { vc.panel.resultTable.numberOfRows == 1 && vc.panel.runButton.isEnabled }
            vc.selectOperation("start"); vc.panel.setValue("true", for: "awake"); vc.panel.setValue(root.path + "/recording.mp4", for: "record")
            vc.panel.runButton.performClick(nil)
            let args = runner.plans.last!.commands[0].arguments
            precondition(args.contains("--serial") && args.contains("--stay-awake") && args.contains("--video-bit-rate") && args.contains(root.path + "/recording.mp4"))
            vc.panel.cancelButton.performClick(nil); precondition(runner.cancelled)
            let window = NSWindow(contentViewController: vc); window.setContentSize(NSSize(width: 800, height: 800)); window.makeKeyAndOrderFront(nil)
            try UIVerification.snapshot(vc.view, to: output)
            window.setContentSize(NSSize(width: 500, height: 500)); vc.view.layoutSubtreeIfNeeded()
            precondition(!vc.view.hasAmbiguousLayout)
            print("PASS: Scrcpy device selection, supported launch flags, recording, stop and compact form layout")
        } else { fatalError("Unsupported feature issue") }
    }
}

private final class FixtureLoginService: LoginItemManaging {
    var state: LoginItemState = .disabled
    var changes: [Bool] = []
    var failure = false
    func setEnabled(_ enabled: Bool) throws {
        if failure { throw ToolInputError(message: "fixture registration failure") }
        changes.append(enabled); state = enabled ? .enabled : .disabled
    }
}
