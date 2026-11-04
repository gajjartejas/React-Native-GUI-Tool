# Validation reference

Supporting rules for repository-root `AGENTS.md`. Select checks by changed scope:

- Documentation/rules only: `git diff --check` and verify referenced paths; no app build.
- Swift or UI behavior: unsigned Debug build and `python3 scripts/test_mvc.py`.
- Xcode/resource changes: also verify project parsing, source membership, and affected connections.
- Review only: source analysis or isolated reproduction appropriate to the finding.

Run each applicable check once after the relevant changes. Repeat only after new
changes, a failure, or unresolved concerns. Capture long build/test output in a
temporary log; return the result and relevant diagnostics.

## Validation

Run commands from the repository root (the directory containing `AGENTS.md` and
`ReactNativeGUITools.xcodeproj`):

```sh
xcodebuild -list -project ReactNativeGUITools.xcodeproj
xcodebuild -project ReactNativeGUITools.xcodeproj -scheme ReactNativeGUITools \
  -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath /tmp/ReactNativeGUITools-DerivedData CODE_SIGNING_ALLOWED=NO build
git diff --check
python3 scripts/test_mvc.py
```

- The repository currently has no Xcode test target. `scripts/test_mvc.py` checks
  View/Model dependencies and compiles a standalone Swift regression runner for
  model persistence, custom actions, and menu/cell presentation. It uses temporary
  fixtures and never starts the application lifecycle or executes project commands.
  Do not claim `xcodebuild test` passed. Extend focused coverage when appropriate.
- For reviews, use read-only analysis or isolated temporary harnesses. Substitute
  in-memory/temporary persistence; never overwrite Application Support data or run
  user scripts just to reproduce a bug.
- For UI changes, verify affected connections, presentation, and state transitions.
  Explicitly distinguish source inspection, automated reproduction, build results,
  and interactive UI testing. Do not claim checks that were not run.
- Before finishing, inspect the diff for MVC boundaries, unrelated edits, deployment
  compatibility, resource membership, and accidental generated/user-specific files.
