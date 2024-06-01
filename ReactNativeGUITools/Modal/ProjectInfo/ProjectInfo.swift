//
//  ProjectInfo.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import AppKit
import Foundation

class ProjectInfo: Codable {
    open var id: String
    open var path: String
    open var name: String?
    open var versionString: String?
    open var scripts: [(name: String, value: String)]?

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
        if let scripts = scripts {
            let scriptsArray = scripts.reduce(into: [String: String]()) { result, script in
                result[script.name] = script.value
            }
            try container.encode(scriptsArray, forKey: .scripts)
        }
    }
}
