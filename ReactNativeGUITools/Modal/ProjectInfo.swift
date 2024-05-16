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
    var scripts: [(name: String, value: String)]?

    init(id: String, path: String) {
        self.id = id
        self.path = path

        let (name, versionString, scripts) = readPackageJSON(atPath: path)
        self.name = name
        self.versionString = versionString
        self.scripts = scripts
    }

    private enum CodingKeys: String, CodingKey {
        case id, path, name, versionString, scripts
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        path = try container.decode(String.self, forKey: .path)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        versionString = try container.decodeIfPresent(String.self, forKey: .versionString)
        // Decode scripts array manually
        if let scriptsArray = try container.decodeIfPresent([String: String].self, forKey: .scripts) {
            scripts = scriptsArray.map { ($0.key, $0.value) }
        } else {
            scripts = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(path, forKey: .path)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(versionString, forKey: .versionString)
        // Encode scripts array manually
        if let scripts = scripts {
            let scriptsArray = scripts.reduce(into: [String: String]()) { result, script in
                result[script.name] = script.value
            }
            try container.encode(scriptsArray, forKey: .scripts)
        }
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

func readPackageJSON(atPath path: String) -> (name: String?, version: String?, scriptsArray: [(name: String, value: String)]?) {
    let packageJSONPath = URL(fileURLWithPath: path).appendingPathComponent("package.json")

    do {
        var name: String?
        var reactNativeVersion: String?
        var scriptsArray: [(name: String, value: String)]?

        let data = try Data(contentsOf: packageJSONPath)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonDict = jsonObject as? [String: Any] else {
            print("Invalid JSON format")
            return (nil, nil, nil)
        }
        name = jsonDict["name"] as? String

        if let dependencies = jsonDict["dependencies"] as? [String: String] {
            print("Error: Could not find dependencies in package.json")
            reactNativeVersion = dependencies["react-native"]
        }

        // Read script
        if let scriptsDict = jsonDict["scripts"] as? [String: String] {
            scriptsArray = scriptsDict.map { (name: $0.key, value: $0.value) }
        }

        return (name, reactNativeVersion, scriptsArray)
    } catch {
        print("Error reading package.json: \(error.localizedDescription)")
        return (nil, nil, nil)
    }
}

func findXcodeProjectFile(atPath path: String) -> String? {
    let fileManager = FileManager.default
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for item in contents {
            if item.hasSuffix(".xcworkspace") {
                return item
            }
        }
        for item in contents {
            if item.hasSuffix(".xcodeproj") {
                return item
            }
        }
    } catch {
        print("Error reading directory: \(error)")
    }
    return nil
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

    func update(with projectInfo: ProjectInfo) {
        if let index = projectInfosAll.firstIndex(where: { $0.id == projectInfo.id }) {
            projectInfosAll[index] = projectInfo
            if let indexInFiltered = projectInfos.firstIndex(where: { $0.id == projectInfo.id }) {
                projectInfos[indexInFiltered] = projectInfo
            }
            _ = ProjectInfo.writeProjectInfos(projectInfosAll)
        }
    }
}
