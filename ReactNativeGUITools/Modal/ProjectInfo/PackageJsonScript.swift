//
//  ProjectInfoPackageJson.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 04/07/24.
//

import Foundation

extension ProjectInfo {
    class PackageJsonScript: Codable {
        open var id: String
        open var name: String
        open var script: String
        
        init(id: String, name: String, script: String) {
            self.id = id
            self.name = name
            self.script = script
        }
    }
}
