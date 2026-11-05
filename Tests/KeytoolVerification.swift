import Cocoa

@MainActor
enum KeytoolVerification {
    static func run(project: ProjectInfo, root: URL) throws {
        precondition(CertificateFingerprints.describe(Data("abc".utf8)).contains("90:01:50:98:3C:D2:4F:B0:D6:96:3F:7D:28:E1:7F:72"))
        let home = "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
        guard FileManager.default.isExecutableFile(atPath: home + "/bin/keytool") else { print("SKIP: live keytool fixture (no fixture JDK)"); return }
        let store = root.appendingPathComponent("fixture.jks").path
        let password = "fixture-only"
        let values = ["keystore":store, "storepass":password, "keypass":password, "alias":"fixture", "type":"JKS", "years":"1", "CN":"Fixture, CI", "C":"US"]
        func execute(_ plan: ToolPlan, success: Bool = true) -> ToolRunResult {
            let runner = StreamingToolRunner(environment: ["JAVA_HOME":home, "PATH":"/usr/bin:/bin"])
            var result: ToolRunResult?; var log = Data()
            runner.run(plan, onOutput: { log.append($0) }, completion: { result = $0 })
            FeatureUIVerification.wait(30) { result != nil }
            precondition(success ? result!.exitCode == 0 : result!.exitCode != 0, result!.output)
            precondition(!String(decoding: log, as: UTF8.self).contains(password), "Password leaked into command log")
            return result!
        }
        _ = execute(try KeytoolPolicy.plan(operation: "generate", values: values, project: project))
        precondition(FileManager.default.fileExists(atPath: store))
        let original = try Data(contentsOf: URL(fileURLWithPath: store))
        let refused = execute(try KeytoolPolicy.plan(operation: "generate", values: values, project: project), success: false)
        let preserved = try Data(contentsOf: URL(fileURLWithPath: store))
        precondition(refused.output.contains("already exists") && preserved == original)
        let listing = execute(try KeytoolPolicy.plan(operation: "inspect", values: values, project: project))
        precondition(listing.output.contains("fixture"))
        let certificate = execute(try KeytoolPolicy.plan(operation: "fingerprints", values: values, project: project))
        let data = try KeytoolPolicy.certificateData(certificate.output)
        precondition(data.count > 100)
        let converted = root.appendingPathComponent("converted.p12").path
        _ = execute(try KeytoolPolicy.plan(operation: "convert", values: ["source":store,"destination":converted,"sourcepass":password,"destpass":password], project: project))
        precondition(FileManager.default.fileExists(atPath: converted))
        print("PASS: real temporary JKS generation, listing, PEM export and PKCS12 conversion; no password logs")
    }
}
