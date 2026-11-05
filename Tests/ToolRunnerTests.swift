import Cocoa

final class RecordingToolRunner: ToolRunning {
    var plans: [ToolPlan] = []
    var completion: ((ToolRunResult) -> Void)?
    var cancelled = false
    func run(_ plan: ToolPlan, onOutput: @escaping (Data) -> Void, completion: @escaping (ToolRunResult) -> Void) {
        plans.append(plan); self.completion = completion
        onOutput(Data("fixture output\n".utf8))
    }
    func cancel() { cancelled = true; completion?(.init(exitCode: 143, cancelled: true, output: "")); completion = nil }
    func finish(output: String = "fixture output") { completion?(.init(exitCode: 0, cancelled: false, output: output)); completion = nil }
}

@MainActor
enum ToolRunnerTests {
    static func run(root: URL) throws {
        let runner = StreamingToolRunner()
        var output = Data(); var result: ToolRunResult?
        runner.run(.init(commands: [.init(executable: "/usr/bin/printf", arguments: ["%s", "space ' Ω $HOME"], directory: root.path)]), onOutput: { output.append($0) }, completion: { result = $0 })
        FeatureUIVerification.wait { result != nil }
        precondition(result?.exitCode == 0 && result?.output == "space ' Ω $HOME")
        precondition(String(decoding: output, as: UTF8.self).contains("space ' Ω $HOME"))
        let pipeline = StreamingToolRunner(); result = nil
        pipeline.run(.init(commands: [.init(executable: "/usr/bin/printf", arguments: ["42"], directory: root.path)], next: { first in
            precondition(first == "42")
            return .init(commands: [.init(executable: "/usr/bin/printf", arguments: ["followup"], directory: root.path)])
        }), onOutput: { _ in }, completion: { result = $0 })
        FeatureUIVerification.wait { result != nil }
        precondition(result?.output == "42followup" && result?.exitCode == 0)
        let cancel = StreamingToolRunner(); result = nil
        cancel.run(.init(commands: [.init(executable: "/bin/sh", arguments: ["-c", "sleep 20 & wait"], directory: root.path)]), onOutput: { _ in }, completion: { result = $0 })
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1)); cancel.cancel()
        FeatureUIVerification.wait { result != nil }
        precondition(result?.cancelled == true)
        print("PASS: streaming output, literal arguments, exit status and child-process cancellation")
    }
}
