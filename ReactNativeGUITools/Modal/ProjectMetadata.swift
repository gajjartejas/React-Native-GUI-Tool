import Foundation

enum ProjectShortcut: String, CaseIterable {
    case finder = "Finder", terminal = "Terminal", editor = "Code Editor", xcode = "Xcode", android = "Android Studio", refresh = "Refresh"
}

struct ProjectMetadata {
    struct Dependency {
        let name: String
        let version: String
        let scope: String
    }
    let summary: String
    let dependencies: [Dependency]

    func filtered(_ query: String) -> [Dependency] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return dependencies.filter { query.isEmpty || "\($0.name) \($0.version) \($0.scope)".localizedCaseInsensitiveContains(query) }
    }

    static func read(path: String, home: String = NSHomeDirectory()) throws -> ProjectMetadata {
        let root = URL(fileURLWithPath: path)
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent("package.json")))
        guard let package = json as? [String: Any] else { throw CocoaError(.fileReadCorruptFile) }
        var dependencies: [Dependency] = []
        for key in ["dependencies", "devDependencies"] {
            let values = package[key] as? [String: String] ?? [:]
            dependencies += values.map { Dependency(name: $0.key, version: $0.value, scope: key) }
        }
        dependencies.sort { $0.name == $1.name ? $0.scope < $1.scope : $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        func version(_ name: String) -> String { dependencies.first { $0.name == name }?.version ?? "Not declared" }
        func matches(_ pattern: String, _ text: String) -> [String] {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
            return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
                Range($0.range(at: 1), in: text).map { String(text[$0]) }
            }
        }
        var bundleIDs = Set<String>()
        let ios = root.appendingPathComponent("ios")
        if FileManager.default.fileExists(atPath: ios.path) {
            for file in try FileManager.default.contentsOfDirectory(at: ios, includingPropertiesForKeys: nil) where file.pathExtension == "xcodeproj" {
                let text = try String(contentsOf: file.appendingPathComponent("project.pbxproj"), encoding: .utf8)
                bundleIDs.formUnion(matches(#"PRODUCT_BUNDLE_IDENTIFIER\s*=\s*\"?([^;\"\n]+)"#, text).map { $0.trimmingCharacters(in: .whitespaces) })
            }
        }
        var applicationIDs = Set<String>()
        for file in ["android/app/build.gradle", "android/app/build.gradle.kts"] {
            let url = root.appendingPathComponent(file)
            if FileManager.default.fileExists(atPath: url.path) {
                let text = try String(contentsOf: url, encoding: .utf8)
                applicationIDs.formUnion(matches(#"(?m)^\s*applicationId\s*(?:=\s*)?["']([^"']+)["']"#, text))
                if applicationIDs.isEmpty { applicationIDs.formUnion(matches(#"(?m)^\s*namespace\s*(?:=\s*)?["']([^"']+)["']"#, text)) }
            }
        }
        let full = root.standardizedFileURL.path
        let components = root.standardizedFileURL.pathComponents
        let homeComponents = URL(fileURLWithPath: home).standardizedFileURL.pathComponents
        let common = zip(components, homeComponents).prefix { $0 == $1 }.count
        let relative = components.starts(with: homeComponents)
            ? "~/" + components.dropFirst(homeComponents.count).joined(separator: "/")
            : (Array(repeating: "..", count: homeComponents.count - common) + components.dropFirst(common)).joined(separator: "/")
        let summary = """
        Name: \(package["name"] as? String ?? "Not declared")
        Version: \(package["version"] as? String ?? "Not declared")
        Private: \((package["private"] as? Bool).map { $0 ? "Yes" : "No" } ?? "Not declared")
        React Native: \(version("react-native"))    React: \(version("react"))
        iOS bundle IDs (build-setting expressions remain unresolved): \(bundleIDs.sorted().joined(separator: ", ").nilIfEmpty ?? "Not found")
        Android application IDs / namespace: \(applicationIDs.sorted().joined(separator: ", ").nilIfEmpty ?? "Not found")
        Absolute path: \(full)
        Home-relative path: \(relative)
        """
        return .init(summary: summary, dependencies: dependencies)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
