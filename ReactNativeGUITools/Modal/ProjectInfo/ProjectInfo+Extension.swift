//
//  ProjectInfo+Extension.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import AppKit
import Foundation

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
