//
//  ToolsOutlineVC+Fixtures.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 23/04/24.
//

import Foundation

extension ToolsOutlineVC {
    static func getDefaultOutlineMenu() -> [MenuNode] {
        return [
            .init(index: 0, title: "Info", iconName: nil, children: [
                .init(index: 0, title: "Project Info", iconName: "info", children: [], nodeType: .parent),
                .init(index: 1, title: "System Info", iconName: "info-mac", children: [], nodeType: .parent),
            ], nodeType: .group),
            .init(index: 1, title: "Package Manager", iconName: nil, children: [
                .init(index: 2, title: "NPM", iconName: "npm", children: [], nodeType: .parent),
                .init(index: 3, title: "Yarn", iconName: "yarn", children: [], nodeType: .parent),
            ], nodeType: .group),
            .init(index: 2, title: "Tools", iconName: nil, children: [
                .init(index: 4, title: "Generate Build", iconName: "build", children: [], nodeType: .parent),
                .init(index: 5, title: "ADB", iconName: "adb", children: [], nodeType: .parent),
                .init(index: 6, title: "Scrcpy", iconName: "scrcpy", children: [], nodeType: .parent),
                .init(index: 7, title: "Apk tool", iconName: "apk", children: [], nodeType: .parent),
                .init(index: 8, title: "Bundletool", iconName: "bundletool", children: [], nodeType: .parent),
                .init(index: 9, title: "Keytool", iconName: "keystore", children: [], nodeType: .parent),
                .init(index: 10, title: "FCM Notification", iconName: "fcm-notification", children: [], nodeType: .parent),
                .init(index: 11, title: "Decrypt IAP Receipt", iconName: "receipt", children: [], nodeType: .parent),
            ], nodeType: .group),
            .init(index: 3, title: "Project Settings", iconName: nil, children: [
                .init(index: 12, title: "Custom Actions", iconName: "custom-actions", children: [], nodeType: .parent),
            ], nodeType: .group),
        ]
    }

    struct NotificationNames {
        static let selectionChanged = "selectionChangedNotification"
    }
}
