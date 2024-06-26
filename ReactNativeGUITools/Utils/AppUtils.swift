//
//  AppUtils.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 25/05/24.
//

import AppKit

func openTerminal(at path: String) {
    let terminalPath = "/usr/bin/open"
    let arguments = ["-a", "Terminal", path]

    let task = Process()
    task.executableURL = URL(fileURLWithPath: terminalPath)
    task.arguments = arguments

    do {
        try task.run()
    } catch {
        print("Error opening Terminal: \(error.localizedDescription)")
    }
}

func launchApplication(at filePath: String, using defaultApp: PathVersion) {
    let url = URL(fileURLWithPath: filePath)
    let defaultAppURL = URL(fileURLWithPath: defaultApp.path)

    // launch configuration
    let config = NSWorkspace.OpenConfiguration()
    config.addsToRecentItems = true
    config.createsNewApplicationInstance = false
    config.allowsRunningApplicationSubstitution = true
    config.activates = true

    if defaultApp.bundleId == .webStorm || defaultApp.bundleId == .androidStudio {
        config.arguments = [filePath]
    } else {
        config.arguments = [url.absoluteString]
    }

    NSWorkspace.shared.open([url], withApplicationAt: defaultAppURL, configuration: config) { app, error in
        if let error = error {
            print("unable to launch app: \(error.localizedDescription)")
            return
        }

        if let app = app {
            print("launched app \(app.processIdentifier)")
        }
    }
}

func openInTerminal(atPath path: String, terminalScript: String) {
    let AppleScriptSrc = """
    tell application "Terminal"
        activate
        if (count of windows) > 0 then
            -- Check if the frontmost tab is busy
            if busy of front window's selected tab then
                -- Open a new tab and run the command
                tell front window
                    set newTab to do script "\(terminalScript)"
                    set selected tab to newTab
                end tell
            else
                -- Run the command in the existing tab
                do script "\(terminalScript)" in front window's selected tab
            end if
        else
            -- Open a new window and run the command
            do script "\(terminalScript)"
        end if
    end tell

    """

    if let AppleScript = NSAppleScript(source: AppleScriptSrc) {
        var error: NSDictionary?
        AppleScript.executeAndReturnError(&error)
        if error != nil {
            print("Error: \(String(describing: error))")
        }
    }
}

func moveFolderToTrash(atPath folderPath: String) {
    let fileManager = FileManager.default

    do {
        // Check if the folder exists
        if fileManager.fileExists(atPath: folderPath) {
            // Move the folder to the Trash
            try fileManager.trashItem(at: URL(fileURLWithPath: folderPath), resultingItemURL: nil)
            print("Folder moved to Trash successfully.")
        } else {
            print("Folder doesn't exist at the specified path.")
        }
    } catch {
        print("Error: \(error)")
    }
}

func readPackageJSON(atPath path: String) -> (name: String?, version: String?, scriptsArray: [(name: String, value: String)]?) {
    let packageJSONPath = URL(fileURLWithPath: path).appendingPathComponent("package.json")

    do {
        var name: String?
        var reactNativeVersion: String?
        var scriptsArray: [(name: String, value: String)]?

        let data = try Data(contentsOf: packageJSONPath)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonDict = jsonObject as? [String: Any] else {
            print("Invalid JSON format")
            return (nil, nil, nil)
        }
        name = jsonDict["name"] as? String

        if let dependencies = jsonDict["dependencies"] as? [String: String] {
            print("Error: Could not find dependencies in package.json")
            reactNativeVersion = dependencies["react-native"]
        }

        // Read script
        if let scriptsDict = jsonDict["scripts"] as? [String: String] {
            scriptsArray = scriptsDict.map { (name: $0.key, value: $0.value) }
        }

        return (name, reactNativeVersion, scriptsArray)
    } catch {
        print("Error reading package.json: \(error.localizedDescription)")
        return (nil, nil, nil)
    }
}

func findXcodeProjectFile(atPath path: String) -> String? {
    let fileManager = FileManager.default
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for item in contents {
            if item.hasSuffix(".xcworkspace") {
                return item
            }
        }
        for item in contents {
            if item.hasSuffix(".xcodeproj") {
                return item
            }
        }
    } catch {
        print("Error reading directory: \(error)")
    }
    return nil
}

func getShortenedString(from input: String?) -> String {
    guard let input = input else { return "-" }
    guard !input.isEmpty else { return "" }

    let delimiters = CharacterSet(charactersIn: " -_")
    let words = input.components(separatedBy: delimiters).filter { !$0.isEmpty }

    if words.count == 1 {
        return String(words[0].prefix(1))
    }

    var result = ""
    if let firstWord = words.first {
        result += String(firstWord.prefix(1))
    }
    if words.count > 1, let secondWord = words.dropFirst().first {
        result += String(secondWord.prefix(1))
    }

    return result
}

func color(for projectName: String) -> NSColor {
    let hash = projectName.hash
    let red = CGFloat((hash & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((hash & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(hash & 0x0000FF) / 255.0

    return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
}

func convertToRelativePaths(from absolutePaths: String) -> String? {
    let paths = absolutePaths.split(separator: "\n").map { String($0) }
    var relativePaths: [String] = []

    guard let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path.components(separatedBy: "/").last else {
        return nil
    }

    for path in paths {
        if let range = path.range(of: homeDirectory) {
            let relativePath = "~" + path[range.upperBound...]
            relativePaths.append(String(relativePath))
        } else {
            relativePaths.append(path)
        }
    }

    return relativePaths.joined(separator: "\\")
}
