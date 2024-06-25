//
//  MainSettings.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 08/06/24.
//

import Foundation

enum AppBundleIdentifier: String, Codable {
    case vscode = "com.microsoft.VSCode"
    case webStorm = "com.jetbrains.WebStorm"
    case webStormEAP = "com.jetbrains.WebStorm-EAP"
    case atom = "com.github.atom"
    case sublimeText = "com.sublimetext.4"
    case nova = "com.panic.Nova"
    case xcode = "com.apple.dt.Xcode"
    case androidStudio = "com.google.android.studio"
    case zed = "dev.zed.Zed"
}

extension AppBundleIdentifier {
    var appName: String {
        switch self {
        case .vscode:
            return "Visual Studio Code"
        case .webStorm:
            return "WebStorm"
        case .webStormEAP:
            return "WebStorm(EAP)"
        case .atom:
            return "Atom"
        case .sublimeText:
            return "Sublime Text"
        case .nova:
            return "Nova"
        case .xcode:
            return "Xcode"
        case .androidStudio:
            return "Android Studio"
        case .zed:
            return "Zed"
        }
    }
}

struct PathVersion: Codable {
    var path: String
    var version: String
    var bundleId: AppBundleIdentifier

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
            for: ["visual", "studio", "code", "webstorm", "atom", "sublime", "text", "nova", "zed"],
            withBundleIdentifiers: [.vscode, .webStorm, .atom, .sublimeText, .nova, .webStormEAP, .zed])
        return paths
    }

    func getXcodesPaths() -> [PathVersion] {
        let paths = getAppPathsAndVersions(for: ["xcode"], withBundleIdentifiers: [.xcode])
        return paths
    }

    func getAndroidStudioPaths() -> [PathVersion] {
        let paths = getAppPathsAndVersions(for: ["android", "studio"], withBundleIdentifiers: [.androidStudio])
        return paths
    }

    func getAppPathsAndVersions(for appNames: [String], withBundleIdentifiers bundleIdentifiers: [AppBundleIdentifier]) -> [PathVersion] {
        let fileManager = FileManager.default
        let applicationsDirectory = "/Applications"
        var appPathsAndVersions = [PathVersion]()

        do {
            let items = try fileManager.contentsOfDirectory(atPath: applicationsDirectory)
            for item in items {
                if appNames.contains(where: { item.lowercased().contains($0.lowercased()) }) && item.hasSuffix(".app") {
                    let fullPath = "\(applicationsDirectory)/\(item)"
                    if let bid = isApp(at: fullPath, withBundleIdentifiers: bundleIdentifiers),
                       let version = getAppVersion(at: fullPath) {
                        appPathsAndVersions.append(PathVersion(path: fullPath, version: version, bundleId: bid))
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

    private func isApp(at path: String, withBundleIdentifiers bundleIdentifiers: [AppBundleIdentifier]) -> AppBundleIdentifier? {
        let bundle = Bundle(path: path)
        if let bundleIdentifier = bundle?.infoDictionary?["CFBundleIdentifier"] as? String {
            return bundleIdentifiers.first(where: { $0.rawValue == bundleIdentifier })
        }
        return nil
    }
}
