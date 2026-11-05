import Foundation

struct ToolField {
    enum Kind { case text, password, toggle, choice([String]), openFile, saveFile }
    let id: String
    let label: String
    var kind: Kind = .text
    var initial: String = ""
}
struct ToolOperation {
    let id: String
    let title: String
    var fields: [ToolField] = []
}
struct ToolSecret {
    let prefix: String
    let value: String
}
struct ToolCommand {
    let executable: String
    let arguments: [String]
    let directory: String
    var environment: [String: String] = [:]
    var secretFiles: [Int: ToolSecret] = [:]
    var newFiles: [String] = []
    var display: String { executable + " " + arguments.map(shellQuoted).joined(separator: " ") }
}
struct ToolPlan {
    var commands: [ToolCommand]
    var outputDirectory: String? = nil
    var next: ((String) throws -> ToolPlan)? = nil
}
struct ToolRunResult {
    let exitCode: Int32
    let cancelled: Bool
    let output: String
}
protocol ToolRunning: AnyObject {
    func run(_ plan: ToolPlan, onOutput: @escaping (Data) -> Void, completion: @escaping (ToolRunResult) -> Void)
    func cancel()
}
struct ToolInputError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
enum ToolInput {
    static func required(_ values: [String: String], _ key: String) throws -> String {
        let value = (values[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, !value.contains("\0") else { throw ToolInputError(message: "Enter \(key).") }
        return value
    }
    static func arguments(_ value: String?) throws -> [String] {
        guard let value = value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        guard let data = value.data(using: .utf8), let args = try? JSONDecoder().decode([String].self, from: data), !args.contains(where: { $0.contains("\0") }) else {
            throw ToolInputError(message: "Arguments must be a JSON array of strings, for example [\"--watch\"].")
        }
        return args
    }
    static func file(_ values: [String: String], _ key: String, extensions: [String]) throws -> String {
        let path = try required(values, key)
        guard path.hasPrefix("/"), extensions.contains(URL(fileURLWithPath: path).pathExtension.lowercased()) else { throw ToolInputError(message: "Choose an absolute \(extensions.joined(separator: "/")) file path for \(key).") }
        return path
    }
    static func package(_ values: [String: String]) throws -> String {
        let value = try required(values, "package")
        guard !value.hasPrefix("-") else { throw ToolInputError(message: "Package names cannot begin with an option flag.") }
        return value
    }
}
