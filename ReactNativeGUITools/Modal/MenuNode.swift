//
//  MenuNode.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

enum MenuType {
    case group
    case parent
    case item
}

class MenuNode {
    var index: Int
    var title: String
    var iconName: String?
    var nodeType: MenuType
    var children: [MenuNode]

    init(index: Int,
         title: String,
         iconName: String?,
         children: [MenuNode] = [],
         nodeType: MenuType = .item) {
        self.index = index
        self.title = title
        self.iconName = iconName
        self.children = children
        self.nodeType = nodeType
    }

    var numberOfChildren: Int {
        children.count
    }

    var hasChildren: Bool {
        !children.isEmpty
    }
}
