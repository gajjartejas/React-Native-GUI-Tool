import Cocoa

@MainActor
enum BundletoolVerification {
    static func execute(_ plan: ToolPlan) -> ToolRunResult {
        let runner = StreamingToolRunner(); var result: ToolRunResult?
        runner.run(plan, onOutput: { _ in }, completion: { result = $0 })
        FeatureUIVerification.wait { result != nil }
        return result!
    }
    static func run(project: ProjectInfo, root: URL) throws {
        let password = "fixture-only"
        let signed = try BundletoolPolicy.plan(operation: "build", values: ["bundle":root.path + "/input.aab", "output":root.path + "/output.apks", "keystore":root.path + "/store.jks", "alias":"fixture", "storepass":password, "mode":"Universal"], project: project)
        precondition(signed.commands[0].secretFiles.count == 2 && !signed.commands[0].display.contains(password))
        let jar = try BundletoolPolicy.plan(operation: "version", values: ["jar":root.path + "/bundletool.jar"], project: project)
        precondition(jar.commands[0].executable == "java" && jar.commands[0].arguments == ["-jar", root.path + "/bundletool.jar", "version"])
        let install = try BundletoolPolicy.plan(operation: "install", values: ["apks":root.path + "/output.apks", "serial":"serial1"], project: project)
        precondition(install.commands[0].arguments.contains("--device-id=serial1"))
        let secure = ToolCommand(executable: "/bin/sh", arguments: ["-c", #"/usr/bin/wc -c < "$1"; /usr/bin/stat -f '%Lp' "$1"; printf '%s' "$1""#, "fixture", "<protected>"], directory: root.path, secretFiles: [3:.init(prefix: "", value: password)])
        let protected = execute(.init(commands: [secure]))
        let lines = protected.output.components(separatedBy: .newlines)
        precondition(protected.exitCode == 0 && Int(lines[0].trimmingCharacters(in: .whitespaces)) == password.utf8.count && lines[1] == "600")
        precondition(!FileManager.default.fileExists(atPath: lines.last!), "Password file survived completion")
        let apk = root.appendingPathComponent("universal.apk")
        try Data("fixture APK bytes".utf8).write(to: apk)
        let archive = root.appendingPathComponent("fixture.apks")
        let zipped = execute(.init(commands: [.init(executable: "/usr/bin/zip", arguments: ["-j", archive.path, apk.path], directory: root.path)]))
        precondition(zipped.exitCode == 0)
        let directory = root.appendingPathComponent("extracted")
        let extract = try BundletoolPolicy.plan(operation: "extract", values: ["apks":archive.path,"directory":directory.path], project: project)
        let extracted = execute(extract); precondition(extracted.exitCode == 0)
        let bytes = try Data(contentsOf: directory.appendingPathComponent("universal.apk"))
        precondition(bytes == Data("fixture APK bytes".utf8))
        precondition(execute(extract).exitCode != 0, "Extraction overwrote an existing APK")
        let link = root.appendingPathComponent("reserved.apks")
        let target = root.appendingPathComponent("missing-target")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
        let refused = execute(.init(commands: [.init(executable: "/usr/bin/printf", arguments: ["not executed"], directory: root.path, newFiles: [link.path])]))
        precondition(refused.exitCode != 0 && !FileManager.default.fileExists(atPath: target.path))
        print("PASS: protected argument file permissions/cleanup and real universal-entry extraction; existing output preserved")
    }
}
