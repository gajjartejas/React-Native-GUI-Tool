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

    private var projectInfosAll: [ProjectInfo] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
        }
    }

    private var projectInfos: [ProjectInfo] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
        }
    }

    private var projectInfosMenu: [ProjectInfo] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
        }
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
        projectInfos = projectInfos.sorted { proj1, proj2 -> Bool in
            switch key {
            case .name:
                return (proj1.name ?? "") < (proj2.name ?? "")
            case .path:
                return proj1.path < proj2.path
            case .versionString:
                return (proj1.versionString ?? "")
                    .replacingOccurrences(of: "^", with: "")
                    .compare((proj2.versionString ?? "")
                        .replacingOccurrences(of: "^", with: ""), options: .numeric) == .orderedDescending
            }
        }
        _ = ProjectInfo.writeArrayToStorage(projectInfos)
    }

    private init() {
        projectInfos = ProjectInfo.readArrayFromStorage() ?? []
        projectInfosAll = ProjectInfo.readArrayFromStorage() ?? []
        projectInfosMenu = ProjectInfo.readArrayFromStorage() ?? []
    }

    func remove(at index: Int, type: UIType) {
        if type == .list {
            let removedItem = projectInfos.remove(at: index)
            projectInfosMenu = projectInfosMenu.filter({ item in
                item.id != removedItem.id
            })
            projectInfosAll = projectInfosAll.filter({ item in
                item.id != removedItem.id
            })
        } else if type == .menu {
            let removedItem = projectInfosMenu.remove(at: index)
            projectInfos = projectInfos.filter({ item in
                item.id != removedItem.id
            })
            projectInfosAll = projectInfosAll.filter({ item in
                item.id != removedItem.id
            })
        }

        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func append(_ projectInfo: ProjectInfo) {
        projectInfosAll.append(projectInfo)
        projectInfos.append(projectInfo)
        projectInfosMenu.append(projectInfo)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func searchBy(_ searchString: String, type: UIType) {
        if type == .list {
            projectInfos = searchBy(array: projectInfosAll, searchString: searchString)
        } else if type == .menu {
            projectInfosMenu = searchBy(array: projectInfosAll, searchString: searchString)
        }
        print(projectInfos)
    }

    func clearSearch(type: UIType) {
        if type == .list {
            projectInfos = ProjectInfo.readArrayFromStorage() ?? []
        } else if type == .menu {
            projectInfosMenu = ProjectInfo.readArrayFromStorage() ?? []
        }

        projectInfosAll = ProjectInfo.readArrayFromStorage() ?? []
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        projectInfos.move(fromOffsets: source, toOffset: destination)
        projectInfosMenu.move(fromOffsets: source, toOffset: destination)
        projectInfosAll.move(fromOffsets: source, toOffset: destination)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func insert(contentsOf newElements: [ProjectInfo], at i: Int) {
        projectInfos.insert(contentsOf: newElements, at: i)
        projectInfosMenu.insert(contentsOf: newElements, at: i)
        projectInfosAll.insert(contentsOf: newElements, at: i)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func append(contentsOf newElements: [ProjectInfo]) {
        projectInfos.append(contentsOf: newElements)
        projectInfosMenu.append(contentsOf: newElements)
        projectInfosAll.append(contentsOf: newElements)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func update(with projectInfo: ProjectInfo) {
        if let index = projectInfosAll.firstIndex(where: { $0.id == projectInfo.id }) {
            projectInfosAll[index] = projectInfo
            if let indexInFiltered = projectInfos.firstIndex(where: { $0.id == projectInfo.id }) {
                projectInfos[indexInFiltered] = projectInfo
            }
            if let indexInFiltered = projectInfosMenu.firstIndex(where: { $0.id == projectInfo.id }) {
                projectInfosMenu[indexInFiltered] = projectInfo
            }
            _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
        }
    }

    func findByPath(project: ProjectInfo, type: UIType) -> Bool {
        if type == .list {
            return projectInfos.contains { item in
                item.path == project.path
            }
        } else if type == .menu {
            return projectInfosMenu.contains { item in
                item.path == project.path
            }
        }
        return false
    }

    func searchBy(array: [ProjectInfo], searchString: String) -> [ProjectInfo] {
        return array.filter { project in
            let versionString = project.versionString ?? ""
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
