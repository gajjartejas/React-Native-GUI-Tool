//
//  ProjectInfoCollection.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Foundation

class ProjectInfoCollection {
    struct NotificationNames {
        static let projectInfoDidChange = Notification.Name("projectInfoDidChange")
    }

    enum SortKey {
        case name
        case path
        case versionString
    }

    static let shared = ProjectInfoCollection()

    open var projectInfosAll: [ProjectInfo] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
        }
    }

    open var projectInfos: [ProjectInfo] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.projectInfoDidChange, object: nil)
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
    }

    func remove(at index: Int) {
        let removedItem = projectInfos.remove(at: index)
        projectInfosAll = projectInfosAll.filter({ item in
            item.id != removedItem.id
        })
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func append(_ projectInfo: ProjectInfo) {
        projectInfosAll.append(projectInfo)
        projectInfos.append(projectInfo)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func searchBy(_ searchString: String) {
        projectInfos = projectInfosAll.filter { project in
            if let name = project.name, let versionString = project.versionString {
                let pureString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
                if pureString.count < 1 {
                    return true
                }
                let searchStringLowercased = pureString.lowercased()
                let nameLowercased = name.lowercased()
                let versionLowercased = versionString.lowercased()
                return nameLowercased.contains(searchStringLowercased) || versionLowercased.contains(searchStringLowercased)
            } else {
                return false
            }
        }
    }

    func clearSearch() {
        projectInfos = ProjectInfo.readArrayFromStorage() ?? []
        projectInfosAll = ProjectInfo.readArrayFromStorage() ?? []
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        projectInfos.move(fromOffsets: source, toOffset: destination)
        projectInfosAll.move(fromOffsets: source, toOffset: destination)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func insert(contentsOf newElements: [ProjectInfo], at i: Int) {
        projectInfos.insert(contentsOf: newElements, at: i)
        projectInfosAll.insert(contentsOf: newElements, at: i)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func append(contentsOf newElements: [ProjectInfo]) {
        projectInfos.append(contentsOf: newElements)
        projectInfosAll.append(contentsOf: newElements)
        _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
    }

    func update(with projectInfo: ProjectInfo) {
        if let index = projectInfosAll.firstIndex(where: { $0.id == projectInfo.id }) {
            projectInfosAll[index] = projectInfo
            if let indexInFiltered = projectInfos.firstIndex(where: { $0.id == projectInfo.id }) {
                projectInfos[indexInFiltered] = projectInfo
            }
            _ = ProjectInfo.writeArrayToStorage(projectInfosAll)
        }
    }

    func findByPath(project: ProjectInfo) -> Bool {
        return projectInfos.contains { item in
            item.path == project.path
        }
    }
}
