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

## Automated AppKit screenshots

After building, run `python3 scripts/test_mvc.py --ui-issue 101` for the
filtered-sort scenario. The runner copies built storyboard/nib resources to a
temporary app, loads real controllers, exercises the scenario, and saves
`docs/verification/issue-101.png`. It redirects Application Support through
`CFFIXED_USER_HOME` to a temporary directory. Screenshots are rendered AppKit
views; this is automated controller verification, not interactive gesture testing.

For any implemented scenario, pass its issue number via `--ui-issue` (101, 104,
87, 88, 102, 103, 105, 106, 108, or 90). The command runs the MVC checks and then
the selected UI scenario in separate temporary homes. `--ui-issue 90
--live-diagnostics` additionally runs installed tools' read-only diagnostic/version
commands, with bounded execution and no package scripts, service starts, or installs.
The live report stays in command output; the committed screenshot uses fixtures.

The additional feature scenarios are 67, 89, 91, 92, 66, 94, 93, 95, 98 and 97.
Run them in one compilation with:

```sh
python3 scripts/test_mvc.py --ui-issues 67 89 91 92 66 94 93 95 98 97
```

Each scenario uses a separate temporary home. Keytool verification conditionally
uses Android Studio's local JDK to generate/inspect/convert disposable keystores.
Bundletool verification uses fixture archives and verifies protected password-file
permissions, cleanup and output preservation; it does not build/install real app
bundles. Device actions and build plans use recording adapters. Signed-app login
registration, physical-device workflows and interactive gestures remain separate
manual checks; do not claim those passed from these screenshots.
