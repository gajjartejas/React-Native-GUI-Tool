//
//  PlistStorable.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 08/06/24.
//

import Foundation

protocol PlistStorable: Codable {
    static var plistFileName: String { get }
}

extension PlistStorable {
    static func plistURL() -> URL? {
        guard let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let plistURL = supportDir.appendingPathComponent(plistFileName)
        return plistURL
    }

    static func readArrayFromStorage() -> [Self]? {
        guard let plistURL = plistURL(),
              let data = try? Data(contentsOf: plistURL),
              let items = try? PropertyListDecoder().decode([Self].self, from: data) else {
            return nil
        }
        return items
    }

    static func writeArrayToStorage(_ items: [Self]) -> Bool {
        guard let plistURL = plistURL(),
              let data = try? PropertyListEncoder().encode(items) else {
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

    static func readFromStorage() -> Self? {
        guard let plistURL = plistURL(),
              let data = try? Data(contentsOf: plistURL),
              let item = try? PropertyListDecoder().decode(Self.self, from: data) else {
            return nil
        }
        return item
    }

    static func writeToStorage(_ item: Self) -> Bool {
        guard let plistURL = plistURL(),
              let data = try? PropertyListEncoder().encode(item) else {
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
