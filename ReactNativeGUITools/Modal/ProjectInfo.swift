//
//  ProjectInfo.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Foundation

class ProjectInfo: Codable {
    var id: String
    var path: String
    var name: String?
    var versionString: String?

    init(id: String, path: String) {
        self.id = id
        self.path = path

        let (name, versionString) = readPackageJSON(atPath: path)
        self.name = name
        self.versionString = versionString
    }
}

extension ProjectInfo {
    // MARK: - Static Methods

    static func plistURL() -> URL? {
        guard let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let plistURL = supportDir.appendingPathComponent("ReactNativeGUITools/browser.plist")
        return plistURL
    }

    static func readProjectInfos() -> [ProjectInfo]? {
        guard let plistURL = plistURL(),
              let data = try? Data(contentsOf: plistURL),
              let projectInfos = try? PropertyListDecoder().decode([ProjectInfo].self, from: data) else {
            return nil
        }
        return projectInfos
    }

    static func writeProjectInfos(_ projectInfos: [ProjectInfo]) -> Bool {
        guard let plistURL = plistURL(),
              let data = try? PropertyListEncoder().encode(projectInfos) else {
            return false
        }
        do {
            try FileManager.default.createDirectory(at: plistURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try data.write(to: plistURL)
            return true
        } catch {
            print("Error writing plist: \(error.localizedDescription)")
            return false
        }
    }
}

func readPackageJSON(atPath path: String) -> (name: String?, version: String?) {
    let packageJSONPath = URL(fileURLWithPath: path).appendingPathComponent("package.json")

    do {
        let data = try Data(contentsOf: packageJSONPath)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonDict = jsonObject as? [String: Any] else {
            print("Invalid JSON format")
            return (nil, nil)
        }

        let name = jsonDict["name"] as? String

        guard let dependencies = jsonDict["dependencies"] as? [String: String] else {
            print("Error: Could not find dependencies in package.json")
            return (nil, nil)
        }
        let reactNativeVersion = dependencies["react-native"]

        return (name, reactNativeVersion)
    } catch {
        print("Error reading package.json: \(error.localizedDescription)")
        return (nil, nil)
    }
}

class ProjectInfoCollection {
    var onChangeProjectInfo: (() -> Void)?

    open var projectInfosAll: [ProjectInfo] {
        didSet {
            onChangeProjectInfo?()
        }
    }
    
    open var projectInfos: [ProjectInfo] {
        didSet {
            onChangeProjectInfo?()
        }
    }


    init() {
        projectInfos = ProjectInfo.readProjectInfos() ?? []
        projectInfosAll = ProjectInfo.readProjectInfos() ?? []
    }

    func remove(at index: Int) {
        let removedItem = projectInfos.remove(at: index)
        projectInfosAll = projectInfosAll.filter({ item in
            item.id != removedItem.id
        })
        _ = ProjectInfo.writeProjectInfos(projectInfosAll)
    }

    func append(_ projectInfo: ProjectInfo) {
        projectInfosAll.append(projectInfo)
        projectInfos.append(projectInfo)
        _ = ProjectInfo.writeProjectInfos(projectInfosAll)
    }

    func searchBy(_ searchString: String) {
        projectInfos = projectInfos.filter { project in
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
        projectInfos = ProjectInfo.readProjectInfos() ?? []
        projectInfosAll = ProjectInfo.readProjectInfos() ?? []
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        projectInfos.move(fromOffsets: source, toOffset: destination)
        projectInfosAll.move(fromOffsets: source, toOffset: destination)
        _ = ProjectInfo.writeProjectInfos(projectInfosAll)
    }

    func insert(contentsOf newElements: [ProjectInfo], at i: Int) {
        projectInfos.insert(contentsOf: newElements, at: i)
        projectInfosAll.insert(contentsOf: newElements, at: i)
        _ = ProjectInfo.writeProjectInfos(projectInfosAll)
    }
    
    func append(contentsOf newElements: [ProjectInfo]) {
        projectInfos.append(contentsOf: newElements)
        projectInfosAll.append(contentsOf: newElements)
        _ = ProjectInfo.writeProjectInfos(projectInfosAll)
    }
}
