//
//  ProjectInfo.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import AppKit
import Foundation

class ProjectInfo: Codable, PlistStorable {
    static var plistFileName: String {
        return "ReactNativeGUITools/browser.plist"
    }

    open var id: String
    open var path: String
    open var name: String?
    open var packageVersionString: String?
    open var packageJsonScripts: [ProjectInfo.PackageJsonScript]?
    open var customMenuScripts: [ProjectInfo.CustomMenuScript]?

    init(id: String, path: String) {
        self.id = id
        self.path = path

        let (name, versionString, scripts) = readPackageJSON(atPath: path)
        self.name = name
        packageVersionString = versionString
        packageJsonScripts = scripts
    }

    private enum CodingKeys: String, CodingKey {
        case id, path, name, packageVersionString, packageScripts, customMenuScripts
    }

    static func == (lhs: ProjectInfo, rhs: ProjectInfo) -> Bool {
        return lhs.path == rhs.path
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        path = try container.decode(String.self, forKey: .path)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        packageVersionString = try container.decodeIfPresent(String.self, forKey: .packageVersionString)
        packageJsonScripts = try container.decodeIfPresent([ProjectInfo.PackageJsonScript].self, forKey: .packageScripts)
        customMenuScripts = try container.decodeIfPresent([ProjectInfo.CustomMenuScript].self, forKey: .customMenuScripts)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(path, forKey: .path)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(packageVersionString, forKey: .packageVersionString)
        try container.encodeIfPresent(packageJsonScripts, forKey: .packageScripts)
        try container.encodeIfPresent(customMenuScripts, forKey: .customMenuScripts)
    }
}
