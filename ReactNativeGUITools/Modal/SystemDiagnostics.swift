import Foundation

struct DiagnosticCheck {
    let title: String
    let executable: String
    let arguments: [String]
}

struct DiagnosticResult {
    enum Status: String {
        case available = "OK"
        case missing = "Not found"
        case failed = "Unavailable"
        case timedOut = "Timed out"
    }

    let title: String
    let status: Status
    let detail: String
}

struct SystemDiagnosticsReport {
    let results: [DiagnosticResult]

    var attentionCount: Int { results.filter { $0.status != .available }.count }

    var text: String {
        (["React Native environment diagnostics"] + results.map {
            "\($0.title) [\($0.status.rawValue)]\n\($0.detail)"
        }).joined(separator: "\n\n")
    }

    static let toolChecks: [DiagnosticCheck] = [
        .init(title: "Node.js", executable: "node", arguments: ["--version"]),
        .init(title: "npm", executable: "npm", arguments: ["--version"]),
        .init(title: "Yarn", executable: "yarn", arguments: ["--version"]),
        .init(title: "Watchman", executable: "watchman", arguments: ["--version"]),
        .init(title: "Watchman service", executable: "watchman", arguments: ["--no-spawn", "--no-local", "--no-pretty", "version"]),
        .init(title: "CocoaPods", executable: "pod", arguments: ["--version"])
    ]

    static func searchPaths(environment: [String: String], home: String) -> [String] {
        let configured = (environment["PATH"] ?? "").split(separator: ":").map(String.init)
        let common = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin",
                      home + "/.volta/bin", home + "/.asdf/shims", home + "/.local/share/mise/shims"]
        var seen = Set<String>()
        return (configured + common).filter { $0.hasPrefix("/") && seen.insert($0).inserted }
    }

    static func androidSDKPath(environment: [String: String], home: String) -> String {
        for key in ["ANDROID_HOME", "ANDROID_SDK_ROOT"] {
            if let path = environment[key], !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return path }
        }
        return home + "/Library/Android/sdk"
    }
}

protocol SystemDiagnosticsScanning: AnyObject {
    /// Deliver on the main queue. Implementations must support cancellation.
    func scan(completion: @escaping (SystemDiagnosticsReport) -> Void)
    func cancel()
}
