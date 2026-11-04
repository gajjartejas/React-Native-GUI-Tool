# Agent instructions

Canonical guidance for Codex and Antigravity; applies to the whole repository.
Keep IDE entry points as references to this file, without duplicating its rules.

## Project and scope

- Native macOS Swift/AppKit tool for React Native projects. Xcode project, target,
  and scheme: `ReactNativeGUITools`; Swift 5 mode; macOS 13.0 minimum.
- Inspect Git status; preserve unrelated work and the current branch. No incidental
  dependencies, migrations, renames, or project-wide formatting.
- Review/triage does not authorize fixes. Honor report-only requests. Commit, push,
  release, and merge only when requested.

## Strict MVC

- `ReactNativeGUITools/Modal/` is Model (keep that existing spelling): domain data,
  validation, parsing, persistence, ordering, and command policies. Foundation-only;
  no UI ownership. Existing managers own shared project/settings state.
- `View/`, storyboards, XIBs, and assets render supplied state and forward intent.
  No manager access, filesystem/network/process work, or business decisions in views.
- `Controller/` handles AppKit lifecycle, input, model calls, presentation, and UI
  delegates. `Utils/` and `Extensions/` provide focused reusable platform adapters.
  AppDelegate only handles lifecycle/wiring.
- No competing architecture. Legacy violations are debt, not examples to copy.
  Report broader scope if compliance requires expanding the requested change.
- Preserve storage keys/IDs, resource connections, target membership, and deployment
  compatibility. Use stable identities, authoritative state, explicit errors, safe
  path/command handling, main-thread UI work, and correctly scoped callback lifetimes.
- Never expose secrets, test against real user settings, or execute project scripts
  or cleanup operations during a review.

## Keep context small

- Read each instruction once per session; reread only when changed or context is lost.
- Start with the requested feature and its direct callers/model/view. Use scoped
  `rg --files` / `rg -n` searches and bounded line ranges. Broaden only when evidence
  requires it; avoid dumping every Swift file, storyboard, log, or issue body.
- Use the project map only when ownership is unclear. Load the task references below
  on demand, not all at startup. They supplement these canonical rules.
- Exclude generated/build output from source exploration; inspect the relevant
  diagnostic excerpt when investigating a build failure.
- Keep tool output and progress summaries concise. Retain useful findings and file
  paths within the session instead of repeating searches or rereading unchanged files.
- Run scope-appropriate required checks; repeat passed checks only after new changes,
  failures, or unresolved concerns. Token savings must not reduce verification.
- When resuming, summarize current scope, changed paths, checks, and next action;
  verify Git state before relying on stale findings. No automatic memory files.

## Load only when relevant

| Task | Reference |
| --- | --- |
| Locate feature ownership | [Project map](docs/agents/project-map.md) |
| Change Swift/UI or review architecture | [Swift/MVC rules](docs/agents/swift-mvc.md) |
| Choose/run checks or report validation | [Validation](docs/agents/validation.md) |
| Search, create, or update issues | [GitHub triage](docs/agents/github.md) |

Finish with the result, checks actually run, limitations, and relevant links.
Inspect the final diff for scope, MVC boundaries, and generated/user-specific files.
