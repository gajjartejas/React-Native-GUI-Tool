//
//  ProjectInfoCustomScript.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 04/07/24.
//

import Foundation

extension ProjectInfo {
    class CustomMenuScript: Codable {
        open var id: String
        open var name: String
        open var script: String
        open var isFileScript: Bool
        
        init(id: String, name: String, script: String, isFileScript: Bool) {
            self.id = id
            self.name = name
            self.script = script
            self.isFileScript = isFileScript
        }
    }
}
