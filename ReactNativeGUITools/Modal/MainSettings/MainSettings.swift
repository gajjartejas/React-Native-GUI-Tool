//
//  MainSettings.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 08/06/24.
//

import Foundation

struct PathVersion: Codable {
    var path: String
    var version: String

    var description: String {
        return "\(path)(\(version))"
    }
}

class MainSettings: Codable, PlistStorable {
    static var plistFileName: String {
        return "ReactNativeGUITools/mainSettings.plist"
    }

    var defaultCodeEditor: PathVersion? = nil
    var defaultXcodePath: PathVersion? = nil
    var defaultAndroidStudio: PathVersion? = nil

    init() {
        if defaultCodeEditor == nil {
            defaultCodeEditor = getCodeEditorsaths().first
        }
        if defaultXcodePath == nil {
            defaultXcodePath = getXcodesPaths().first
        }
        if defaultAndroidStudio == nil {
            defaultAndroidStudio = getAndroidStudioPaths().first
        }
    }

    func getCodeEditorsaths() -> [PathVersion] {
        let paths = getAppPathsAndVersions(
            for: ["visual", "studio", "code", "webstorm", "atom", "sublime", "text", "nova"],
            withBundleIdentifiers: ["com.microsoft.VSCode", "com.jetbrains.WebStorm", "com.github.atom", "com.sublimetext.4", "com.panic.Nova"])
        return paths
    }

    func getXcodesPaths() -> [PathVersion] {
        let paths = getAppPathsAndVersions(for: ["xcode"], withBundleIdentifiers: ["com.apple.dt.Xcode"])
        return paths
    }

    func getAndroidStudioPaths() -> [PathVersion] {
        let paths = getAppPathsAndVersions(for: ["android", "studio"], withBundleIdentifiers: ["com.google.android.studio"])
        return paths
    }

    func getAppPathsAndVersions(for appNames: [String], withBundleIdentifiers bundleIdentifiers: [String]) -> [PathVersion] {
        let fileManager = FileManager.default
        let applicationsDirectory = "/Applications"
        var appPathsAndVersions = [PathVersion]()

        do {
            let items = try fileManager.contentsOfDirectory(atPath: applicationsDirectory)
            for item in items {
                if appNames.contains(where: { item.lowercased().contains($0.lowercased()) }) && item.hasSuffix(".app") {
                    let fullPath = "\(applicationsDirectory)/\(item)"
                    if isApp(at: fullPath, withBundleIdentifiers: bundleIdentifiers), let version = getAppVersion(at: fullPath) {
                        appPathsAndVersions.append(PathVersion(path: fullPath, version: version))
                    }
                }
            }
        } catch {
            print("Error while enumerating files in \(applicationsDirectory): \(error.localizedDescription)")
        }

        return appPathsAndVersions
    }

    private func getAppVersion(at path: String) -> String? {
        let bundle = Bundle(path: path)
        return bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    private func isApp(at path: String, withBundleIdentifiers bundleIdentifiers: [String]) -> Bool {
        let bundle = Bundle(path: path)
        if let bundleIdentifier = bundle?.infoDictionary?["CFBundleIdentifier"] as? String {
            return bundleIdentifiers.contains(bundleIdentifier)
        }
        return false
    }
}
