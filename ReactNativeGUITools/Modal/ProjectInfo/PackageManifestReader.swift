import Foundation

func readPackageJSON(atPath path: String) -> (name: String?, version: String?, scriptsArray: [ProjectInfo.PackageJsonScript]?) {
    let packageJSONPath = URL(fileURLWithPath: path).appendingPathComponent("package.json")

    do {
        var name: String?
        var reactNativeVersion: String?
        var scriptsArray: [ProjectInfo.PackageJsonScript]?

        let data = try Data(contentsOf: packageJSONPath)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonDict = jsonObject as? [String: Any] else {
            print("Invalid JSON format")
            return (nil, nil, nil)
        }
        name = jsonDict["name"] as? String

        if let dependencies = jsonDict["dependencies"] as? [String: String] {
            reactNativeVersion = dependencies["react-native"]
        }

        // Read script
        if let scriptsDict = jsonDict["scripts"] as? [String: String] {
            scriptsArray = scriptsDict.map { ProjectInfo.PackageJsonScript(id: UUID().uuidString, name: $0.key, script: $0.value) }
        }

        return (name, reactNativeVersion, scriptsArray)
    } catch {
        print("Error reading package.json: \(error.localizedDescription)")
        return (nil, nil, nil)
    }
}
