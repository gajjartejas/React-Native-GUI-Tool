import Cocoa

private struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

private func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() { throw TestFailure(description: message) }
}

private final class MenuDelegateSpy: ProjectListMenuDelegate {
    var events: [String] = []
    func projectListMenuNeedsUpdate(_ menu: NSMenu) { events.append("refresh") }
    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int) { events.append("open:\(row)") }
    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int) { events.append("rename:\(row)") }
    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int) { events.append("remove:\(row)") }
}

/// Standalone regression runner; never launches Terminal or reads/writes app settings.
@main
private struct MVCRegressionTests {
    static func main() throws {
        _ = NSApplication.shared
        if let issue = ProcessInfo.processInfo.environment["RNGUI_UI_ISSUE"],
           let output = ProcessInfo.processInfo.environment["RNGUI_UI_SCREENSHOT"] {
            try UIVerification.run(issue: issue, output: URL(fileURLWithPath: output))
            return
        }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let manifest = directory.appendingPathComponent("package.json")
        try Data("""
        {"name":"Fixture", "dependencies":{"react-native":"0.75.0"},
         "scripts":{"z-extra":"echo z", "ios":"react-native run-ios", "start":"react-native start", "test":"jest"}}
        """.utf8).write(to: manifest)
        let project = ProjectInfo(id: "project-id", path: directory.path)
        try expect(project.name == "Fixture" && project.packageVersionString == "0.75.0", "Manifest metadata was lost")
        try expect(project.orderedPackageJsonScripts?.map(\.name) == ["start", "test", "ios", "z-extra"], "Package scripts lost their presentation order")
        let missingManifest = readPackageJSON(atPath: directory.appendingPathComponent("missing").path)
        try expect(missingManifest.name == nil && missingManifest.scriptsArray == nil, "Missing manifest should return no metadata")
        print("PASS: manifest parsing and package-script ordering")

        do {
            _ = try ProjectInfo.CustomMenuScript.validated(name: " \n", script: "echo hello")
            throw TestFailure(description: "Blank action name accepted")
        } catch ProjectInfo.CustomMenuScript.ValidationError.emptyName {}
        do {
            _ = try ProjectInfo.CustomMenuScript.validated(name: "Run", script: " \n")
            throw TestFailure(description: "Blank action script accepted")
        } catch ProjectInfo.CustomMenuScript.ValidationError.emptyScript {}
        let first = try ProjectInfo.CustomMenuScript.validated(name: " One ", script: " ./one.sh ", id: "one")
        let second = try ProjectInfo.CustomMenuScript.validated(name: "Two", script: "echo two", id: "two")
        try expect(first.name == "One" && first.script == "./one.sh" && first.isFileScript, "Script normalization changed")
        try expect(!second.isFileScript, "Inline command classified as a file")
        print("PASS: model validation and script classification")

        project.appendCustomScript(first)
        project.appendCustomScript(second)
        let edited = try ProjectInfo.CustomMenuScript.validated(name: "Edited", script: "echo edited", id: "one")
        try expect(project.replaceCustomScript(edited), "Existing action could not be edited")
        try expect(project.swapCustomScripts(at: 0, and: 1), "Move-down failed")
        try expect(project.customMenuScripts?.map(\.id) == ["two", "one"], "Move-down changed action identity")
        try expect(project.moveCustomScript(from: 1, to: 0), "Drag reorder failed")
        try expect(project.customMenuScripts?.map(\.id) == ["one", "two"], "Drag reorder changed action identity")
        try expect(!project.moveCustomScript(from: 8, to: 0), "Invalid source index accepted")
        try expect(!project.removeCustomScript(at: -1), "Invalid removal accepted")
        try expect(project.removeCustomScript(at: 1), "Removal failed")
        try expect(project.customMenuScripts?.first?.name == "Edited", "Edit was lost through reordering")
        print("PASS: custom-action lifecycle and invalid selections")

        let other = ProjectInfo(id: "other-id", path: directory.path)
        let third = ProjectInfo(id: "third-id", path: directory.path)
        let projects = [project, other, third]
        try expect(ProjectOrdering.moving(projects, fromOffsets: IndexSet(integer: 0), toOffset: 3).map(\.id) == ["other-id", "third-id", "project-id"], "Downward project move lost identity/order")
        try expect(ProjectOrdering.moving(projects, fromOffsets: IndexSet([1, 2]), toOffset: 0).map(\.id) == ["other-id", "third-id", "project-id"], "Multi-project move lost relative order")
        try expect(ProjectOrdering.moving(projects, fromOffsets: IndexSet(integer: 1), toOffset: 2).map(\.id) == projects.map(\.id), "Drop immediately after source should preserve order")
        try expect(!project.rename(to: " \n") && project.name == "Fixture", "Blank rename changed the project")
        try expect(project.rename(to: " Renamed ") && project.name == "Renamed", "Rename normalization failed")
        print("PASS: project ordering and rename policy")

        let manager = ProjectInfoManager.shared
        project.name = "Beta"
        other.name = "Alpha"
        project.packageVersionString = "0.75.0"
        other.packageVersionString = "0.76.0"
        manager.append(contentsOf: [project, other])
        manager.searchBy("Beta", type: .list)
        manager.searchBy("Alpha", type: .menu)
        for key: ProjectInfoManager.SortKey in [.name, .path, .versionString] {
            manager.sorted(by: key)
            try expect(manager.get(type: .all).count == 2, "Sorting discarded hidden projects")
            try expect(ProjectInfo.readArrayFromStorage()?.count == 2, "Sorting persisted a filtered subset")
            try expect(manager.get(type: .list).map(\.id) == [project.id], "Sort lost list filter")
            try expect(manager.get(type: .menu).map(\.id) == [other.id], "Sort lost menu filter")
        }
        manager.clearSearch(type: .list)
        manager.clearSearch(type: .menu)
        try expect(manager.get(type: .list).count == 2 && manager.get(type: .menu).count == 2, "Clearing search lost registrations")
        print("PASS: filtered sorting preserves storage and independent projections")

        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        let data = try encoder.encode(project)
        let decoded = try decoder.decode(ProjectInfo.self, from: data)
        try expect(decoded.id == project.id && decoded.path == project.path, "Project identity changed during persistence")
        try expect(decoded.customMenuScripts?.first?.id == "one", "Custom action identity was not persisted")
        try expect(decoded.packageJsonScripts?.count == 4, "Existing packageScripts coding key no longer round-trips")
        guard var legacy = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            throw TestFailure(description: "Encoded project was not a property-list dictionary")
        }
        legacy.removeValue(forKey: "customMenuScripts")
        let legacyData = try PropertyListSerialization.data(fromPropertyList: legacy, format: .xml, options: 0)
        let legacyProject = try decoder.decode(ProjectInfo.self, from: legacyData)
        try expect(legacyProject.customMenuScripts == nil && legacyProject.id == "project-id", "Legacy plist without custom scripts no longer decodes")
        print("PASS: plist round-trip and legacy compatibility")

        let controller = ProjectListMenuController()
        let spy = MenuDelegateSpy()
        controller.delegate = spy
        let menu = controller.createMenuFrom(projectInfos: [project], row: 0)
        try verifyActions(in: menu, target: controller)
        try expect(menu.items.first(where: { $0.title == "Script" })?.submenu?.items.first?.title == "start", "Menu did not render model script order")
        controller.openAction(menu.items[0])
        controller.renameAction(menu.items[0])
        controller.removeAction(menu.items[0])
        controller.menuNeedsUpdate(menu)
        try expect(spy.events == ["open:0", "rename:0", "remove:0", "refresh"], "Menu intent was not delegated to its owner")
        controller.refreshMenu(menu)
        try verifyActions(in: menu, target: controller)
        let customItem = menu.items.first(where: { $0.title == "Custom Actions" })?.submenu?.items.first
        try expect((customItem?.representedObject as? ProjectInfo.CustomMenuScript)?.id == "one", "Refreshed action lost its model identity")
        let emptyMenu = controller.createMenuFrom(projectInfos: [], row: nil)
        try expect(emptyMenu.items.first(where: { $0.title == "Script" })?.isEnabled == false, "Empty menu script state changed")
        try verifyActions(in: emptyMenu, target: controller)
        print("PASS: menu rendering, action targets, refresh, and delegated intent")

        let cell = ProjectListCellView(frame: .zero)
        cell.projectLogoView = NSView()
        cell.projectLogoLable = NSTextField()
        cell.projectNameLable = NSTextField()
        cell.projectPathLable = NSTextField()
        cell.projectVersion = NSTextField()
        cell.projectVersionLable = NSView()
        cell.configureUI(withNode: project, atRow: 0, isProjectAvailable: false)
        try expect(cell.projectLogoLable.stringValue == "?" && cell.projectNameLable.textColor == .red, "Cell ignored supplied unavailable state")
        cell.configureUI(withNode: project, atRow: 0, isProjectAvailable: true)
        try expect(cell.projectLogoLable.stringValue != "?" && cell.projectNameLable.textColor == .labelColor, "Cell did not render supplied available state")
        print("PASS: cell renders controller-supplied availability")
        print("All MVC regression groups passed.")
    }

    private static func verifyActions(in menu: NSMenu, target: ProjectListMenuController) throws {
        for item in menu.items {
            if item.submenu == nil, item.isEnabled, let action = item.action {
                try expect((item.target as AnyObject?) === target, "Wrong action target for \(item.title)")
                try expect(target.responds(to: action), "Unimplemented selector for \(item.title)")
            }
            if let submenu = item.submenu { try verifyActions(in: submenu, target: target) }
        }
    }
}
