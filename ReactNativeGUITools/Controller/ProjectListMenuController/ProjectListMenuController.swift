import Cocoa

protocol ProjectListMenuDelegate: AnyObject {
    func projectListMenuNeedsUpdate(_ menu: NSMenu)
    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int)
    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int)
    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int)
}

final class ProjectListMenuController: NSObject {
    var clickedRow: Int?
    private(set) var projectInfos: [ProjectInfo] = []
    weak var delegate: ProjectListMenuDelegate?
    private let menuView = ProjectListMenu()

    func setClickedRow(_ row: Int?) {
        clickedRow = row
    }

    func createMenuFrom(projectInfos: [ProjectInfo], row: Int?) -> NSMenu {
        self.projectInfos = projectInfos
        clickedRow = row
        return menuView.createMenuFrom(projectInfos: projectInfos, row: row, target: self)
    }

    func refreshMenu(_ menu: NSMenu) {
        guard let row = clickedRow else { return }
        menuView.refreshMenu(menu, project: projectInfos[row], target: self)
    }
}
