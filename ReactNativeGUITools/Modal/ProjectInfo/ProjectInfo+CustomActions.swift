import Foundation

extension ProjectInfo {
    func appendCustomScript(_ script: CustomMenuScript) {
        if customMenuScripts == nil {
            customMenuScripts = []
        }
        customMenuScripts?.append(script)
    }

    @discardableResult
    func replaceCustomScript(_ script: CustomMenuScript) -> Bool {
        guard let index = customMenuScripts?.firstIndex(where: { $0.id == script.id }) else { return false }
        customMenuScripts?[index] = script
        return true
    }

    @discardableResult
    func removeCustomScript(at index: Int) -> Bool {
        guard let scripts = customMenuScripts, scripts.indices.contains(index) else { return false }
        customMenuScripts?.remove(at: index)
        return true
    }

    @discardableResult
    func swapCustomScripts(at source: Int, and destination: Int) -> Bool {
        guard var scripts = customMenuScripts,
              scripts.indices.contains(source), scripts.indices.contains(destination) else { return false }
        scripts.swapAt(source, destination)
        customMenuScripts = scripts
        return true
    }

    @discardableResult
    func moveCustomScript(from source: Int, to destination: Int) -> Bool {
        guard var scripts = customMenuScripts,
              scripts.indices.contains(source), scripts.indices.contains(destination) else { return false }
        let script = scripts.remove(at: source)
        scripts.insert(script, at: destination)
        customMenuScripts = scripts
        return true
    }

    func customScriptPath(for selectedPath: String) -> String {
        let projectComponents = URL(fileURLWithPath: path).standardizedFileURL.pathComponents
        let selectedComponents = URL(fileURLWithPath: selectedPath).standardizedFileURL.pathComponents
        guard selectedComponents.starts(with: projectComponents) else { return selectedPath }
        let relative = selectedComponents.dropFirst(projectComponents.count).joined(separator: "/")
        return relative.isEmpty ? "$PROJECT_ROOT" : "$PROJECT_ROOT/\(relative)"
    }

    static func isDirectory(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}

extension ProjectInfo.CustomMenuScript {
    enum ValidationError: Error {
        case emptyName
        case emptyScript
    }

    static func validated(name: String, script: String, id: String? = nil) throws -> ProjectInfo.CustomMenuScript {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let script = script.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw ValidationError.emptyName }
        guard !script.isEmpty else { throw ValidationError.emptyScript }
        let isFileScript = script.hasPrefix("/") || script.hasPrefix("$PROJECT_ROOT") || script.hasPrefix("./")
        return ProjectInfo.CustomMenuScript(id: id ?? UUID().uuidString, name: name, script: script, isFileScript: isFileScript)
    }
}
