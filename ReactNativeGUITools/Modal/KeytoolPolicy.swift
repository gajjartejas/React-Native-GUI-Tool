import Foundation

enum KeytoolPolicy {
    static func operations(project: ProjectInfo) -> [ToolOperation] {
        let store = ToolField(id: "keystore", label: "Keystore file", kind: .openFile)
        let password = ToolField(id: "storepass", label: "Store password", kind: .password)
        let alias = ToolField(id: "alias", label: "Key alias", initial: "release")
        return [
            .init(id: "version", title: "Check keytool / JDK", fields: []),
            .init(id: "generate", title: "Generate keystore / key pair", fields: [
                .init(id: "keystore", label: "New keystore path", kind: .saveFile, initial: project.path + "/release.p12"), alias, password,
                .init(id: "keypass", label: "Key password (blank = store)", kind: .password),
                .init(id: "type", label: "Keystore format", kind: .choice(["PKCS12", "JKS"])),
                .init(id: "years", label: "Validity (years)", initial: "25"),
                .init(id: "CN", label: "Certificate common name", initial: "Release"),
                .init(id: "OU", label: "Organizational unit"), .init(id: "O", label: "Organization"),
                .init(id: "L", label: "Locality / city"), .init(id: "ST", label: "State / province"), .init(id: "C", label: "Country (2 letters)")
            ]),
            .init(id: "inspect", title: "Inspect keystore / list aliases", fields: [store, password, .init(id: "alias", label: "Alias (blank = all)")]),
            .init(id: "fingerprints", title: "Certificate fingerprints (MD5, SHA-1, SHA-256)", fields: [store, password, alias]),
            .init(id: "convert", title: "Convert JKS to PKCS12", fields: [
                .init(id: "source", label: "Source JKS", kind: .openFile), .init(id: "destination", label: "New PKCS12 file", kind: .saveFile),
                .init(id: "sourcepass", label: "Source store password", kind: .password), .init(id: "destpass", label: "Destination password", kind: .password),
                .init(id: "alias", label: "Source alias (optional)"), .init(id: "keypass", label: "Source key password (optional)", kind: .password)
            ])
        ]
    }
    static func secret(_ values: [String: String], _ key: String) throws -> String {
        guard let value = values[key], value.count >= 6, !value.contains("\0"), !value.contains("\n"), !value.contains("\r") else { throw ToolInputError(message: "\(key) must contain at least 6 characters without line breaks.") }
        return value
    }
    static func certificateData(_ output: String) throws -> Data {
        guard let begin = output.range(of: "-----BEGIN CERTIFICATE-----"), let end = output.range(of: "-----END CERTIFICATE-----", range: begin.upperBound..<output.endIndex),
              let data = Data(base64Encoded: String(output[begin.upperBound..<end.lowerBound]), options: .ignoreUnknownCharacters), !data.isEmpty else { throw ToolInputError(message: "Certificate output was not valid PEM.") }
        return data
    }
    static func plan(operation: String, values: [String: String], project: ProjectInfo) throws -> ToolPlan {
        var env: [String: String] = [:]
        var args: [String]
        var newFiles: [String] = []
        let types = ["jks", "keystore", "p12", "pfx", "pkcs12"]
        switch operation {
        case "version": args = ["-help"]
        case "generate":
            let store = try ToolInput.file(values, "keystore", extensions: types)
            newFiles = [store]
            let alias = try ToolInput.required(values, "alias")
            let password = try secret(values, "storepass")
            let keypass = (values["keypass"] ?? "").isEmpty ? password : try secret(values, "keypass")
            let type = values["type"] ?? "PKCS12"
            guard ["PKCS12", "JKS"].contains(type) else { throw ToolInputError(message: "Choose JKS or PKCS12.") }
            guard type != "PKCS12" || keypass == password else { throw ToolInputError(message: "PKCS12 requires matching store and key passwords.") }
            guard let years = Int(try ToolInput.required(values, "years")), (1...100).contains(years) else { throw ToolInputError(message: "Validity must be between 1 and 100 years.") }
            _ = try ToolInput.required(values, "CN")
            let country = values["C"] ?? ""
            guard country.isEmpty || country.range(of: "^[A-Za-z]{2}$", options: .regularExpression) != nil else { throw ToolInputError(message: "Use a two-letter country code.") }
            let dn = ["CN", "OU", "O", "L", "ST", "C"].compactMap { key -> String? in
                guard let value = values[key], !value.isEmpty else { return nil }
                return key + "=\"" + value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
            }.joined(separator: ",")
            env = ["RNGUI_STORE_PASSWORD":password, "RNGUI_KEY_PASSWORD":keypass]
            args = ["-genkeypair", "-keyalg", "RSA", "-keysize", "2048", "-sigalg", "SHA256withRSA", "-keystore", store, "-alias", alias, "-storetype", type, "-validity", String(years * 365), "-dname", dn, "-storepass:env", "RNGUI_STORE_PASSWORD", "-keypass:env", "RNGUI_KEY_PASSWORD"]
        case "inspect", "fingerprints":
            env["RNGUI_STORE_PASSWORD"] = try secret(values, "storepass")
            args = operation == "inspect" ? ["-list", "-v"] : ["-exportcert", "-rfc"]
            args += ["-keystore", try ToolInput.file(values, "keystore", extensions: types), "-storepass:env", "RNGUI_STORE_PASSWORD"]
            if operation == "fingerprints" { args += ["-alias", try ToolInput.required(values, "alias")] }
            else if let alias = values["alias"], !alias.isEmpty { args += ["-alias", alias] }
        case "convert":
            env = ["RNGUI_SOURCE_PASSWORD":try secret(values, "sourcepass"), "RNGUI_DEST_PASSWORD":try secret(values, "destpass")]
            args = ["-importkeystore", "-srckeystore", try ToolInput.file(values, "source", extensions: ["jks", "keystore"]), "-srcstoretype", "JKS", "-destkeystore", try ToolInput.file(values, "destination", extensions: ["p12", "pfx", "pkcs12"]), "-deststoretype", "PKCS12", "-srcstorepass:env", "RNGUI_SOURCE_PASSWORD", "-deststorepass:env", "RNGUI_DEST_PASSWORD", "-noprompt"]
            newFiles = [try ToolInput.file(values, "destination", extensions: ["p12", "pfx", "pkcs12"])]
            if let alias = values["alias"], !alias.isEmpty { args += ["-srcalias", alias, "-destkeypass:env", "RNGUI_DEST_PASSWORD"] }
            if let password = values["keypass"], !password.isEmpty {
                guard !(values["alias"] ?? "").isEmpty else { throw ToolInputError(message: "Specify a source alias when providing its key password.") }
                env["RNGUI_KEY_PASSWORD"] = try secret(values, "keypass"); args += ["-srckeypass:env", "RNGUI_KEY_PASSWORD"]
            }
        default: throw ToolInputError(message: "Choose a keytool operation.")
        }
        return .init(commands: [.init(executable: "keytool", arguments: args, directory: project.path, environment: env, newFiles: newFiles)])
    }
}
