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
        } else { fatalError("Unsupported feature issue") }
    }
}
