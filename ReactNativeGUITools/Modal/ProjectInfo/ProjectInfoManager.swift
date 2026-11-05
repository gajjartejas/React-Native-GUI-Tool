//
//  ProjectInfoManager.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Foundation

class ProjectInfoManager {
    struct NotificationNames {
        static let projectInfoDidChange = Notification.Name("projectInfoDidChange")
    }

    enum SortKey {
        case name
        case path
        case versionString
    }

    enum UIType {
        case list
        case menu
        case all
    }

    static let shared = ProjectInfoManager()

    private var projectInfosAll: [ProjectInfo]
    private var listSearch = ""
    private var menuSearch = ""

    private var projectInfos: [ProjectInfo] {
        searchBy(array: projectInfosAll, searchString: listSearch)
    }

    private var projectInfosMenu: [ProjectInfo] {
        searchBy(array: projectInfosAll, searchString: menuSearch)
    }

    private func publishChanges(persist: Bool = true) {
        if persist { _ = ProjectInfo.writeArrayToStorage(projectInfosAll) }
        NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
    }

    func get(type: UIType) -> [ProjectInfo] {
        switch type {
        case .list:
            return projectInfos
        case .menu:
            return projectInfosMenu
        case .all:
            return projectInfosAll
        }
    }

    func sorted(by key: SortKey) {
        projectInfosAll = projectInfosAll.sorted { (proj1: ProjectInfo, proj2: ProjectInfo) -> Bool in
            switch key {
            case .name:
                return (proj1.name ?? "") < (proj2.name ?? "")
            case .path:
                return proj1.path < proj2.path
            case .versionString:
                return (proj1.packageVersionString ?? "")
                    .replacingOccurrences(of: "^", with: "")
                    .compare((proj2.packageVersionString ?? "")
                        .replacingOccurrences(of: "^", with: ""), options: .numeric) == .orderedDescending
            }
        }
        publishChanges()
    }

    private init() {
        projectInfosAll = ProjectInfo.readArrayFromStorage() ?? []
    }

    func remove(at index: Int, type: UIType) {
        let visible = get(type: type)
        guard visible.indices.contains(index) else { return }
        projectInfosAll.removeAll { $0.id == visible[index].id }
        publishChanges()
    }

    func append(_ projectInfo: ProjectInfo) {
        append(contentsOf: [projectInfo])
    }

    func searchBy(_ searchString: String, type: UIType) {
        if type == .list { listSearch = searchString }
        if type == .menu { menuSearch = searchString }
        publishChanges(persist: false)
    }

    func clearSearch(type: UIType) {
        searchBy("", type: type)
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        // The table disables reordering while filtered.
        guard listSearch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        projectInfosAll = ProjectOrdering.moving(projectInfosAll, fromOffsets: source, toOffset: destination)
        publishChanges()
    }

    func insert(contentsOf newElements: [ProjectInfo], at i: Int) {
        let visible = projectInfos
        guard (0...visible.count).contains(i) else { return }
        let target = i < visible.count
            ? projectInfosAll.firstIndex(where: { $0.id == visible[i].id }) ?? projectInfosAll.count
            : projectInfosAll.count
        projectInfosAll.insert(contentsOf: newElements, at: target)
        publishChanges()
    }

    /// Validate the whole batch before publishing a single insertion.
    @discardableResult
    func importProjects(_ candidates: [ProjectInfo], at index: Int,
                        confirmDuplicate: (ProjectInfo) -> Bool) -> Bool {
        guard (0...projectInfos.count).contains(index) else { return false }
        let existing = Set(projectInfosAll.map { URL(fileURLWithPath: $0.path).standardizedFileURL.path })
        var seen = Set<String>()
        let approved = candidates.filter { project in
            let path = URL(fileURLWithPath: project.path).standardizedFileURL.path
            guard seen.insert(path).inserted else { return false }
            return !existing.contains(path) || confirmDuplicate(project)
        }
        if !approved.isEmpty { insert(contentsOf: approved, at: index) }
        return true
    }

    func append(contentsOf newElements: [ProjectInfo]) {
        projectInfosAll.append(contentsOf: newElements)
        publishChanges()
    }

    func update(with projectInfo: ProjectInfo) {
        guard let index = projectInfosAll.firstIndex(where: { $0.id == projectInfo.id }) else { return }
        projectInfosAll[index] = projectInfo
        publishChanges()
    }

    func findByPath(project: ProjectInfo, type: UIType) -> Bool {
        get(type: type).contains { $0.path == project.path }
    }

    func searchBy(array: [ProjectInfo], searchString: String) -> [ProjectInfo] {
        return array.filter { (project: ProjectInfo) in
            let versionString = project.packageVersionString ?? ""
            let name = project.name ?? ""
            let pureString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
            if pureString.count < 1 {
                return true
            }
            let searchStringLowercased = pureString.lowercased()
            let nameLowercased = name.lowercased()
            let versionLowercased = versionString.lowercased()
            return nameLowercased.contains(searchStringLowercased) || versionLowercased.contains(searchStringLowercased)
        }
    }
}
