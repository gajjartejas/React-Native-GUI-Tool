//
//  ProjectInfo.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Foundation

class ProjectInfo {
    var name: String
    var path: String
    var versionString: String

    init(name: String, path: String, versionString: String) {
        self.name = name
        self.path = path
        self.versionString = versionString
    }
}
