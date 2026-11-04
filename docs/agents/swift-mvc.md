# Swift and MVC reference

Supporting rules for the canonical repository-root `AGENTS.md`. Read for Swift/UI
changes or architecture reviews; load only sections relevant to the task.

## Mandatory architecture: Model-View-Controller

All new or changed application behavior must follow MVC. Do not introduce MVVM,
VIPER, coordinators, reducers, or a competing architecture. Existing violations
are legacy debt, not examples to copy or permission for an unsolicited refactor.
If strict compliance requires a broader change, report that scope before doing it.

| Layer | Location | Responsibilities |
| --- | --- | --- |
| Model | `ReactNativeGUITools/Modal/` | Domain entities, validation, project/settings state, parsing, persistence, and model managers. The existing spelling `Modal` means Model here; do not rename it without a dedicated migration. |
| View | `ReactNativeGUITools/View/`, storyboards, XIBs, assets | Layout, drawing, accessibility, display of supplied values, and forwarding user intent. |
| Controller | `ReactNativeGUITools/Controller/` | AppKit lifecycle, input collection, model calls, rendering model results, window/sheet presentation, and table/outline delegate/data-source adaptation. |
| Shared infrastructure | `ReactNativeGUITools/Utils/`, `Extensions/` | Focused reusable platform/I/O adapters and type extensions; never a second source of application state or a dumping ground for feature logic. |

- Models must not own or manipulate views, windows, menus, outlets, or controllers.
  Prefer Foundation-only domain code; put AppKit presentation and integration
  details in views/controllers or focused infrastructure adapters.
- Views must not read or write plist storage, call shared model managers, discover
  installed tools, parse package manifests, execute scripts, or decide business
  behavior. Send events through delegates, target/action, or closures to a controller.
- Controllers translate view events into model operations and render the result.
  Keep domain validation, sorting/filtering rules, persistence, and command
  construction out of controllers; delegate them to model-layer collaborators.
- Reusable menus/cells are views. Their controllers own business actions and
  execution. Do not add new model-manager or filesystem/process calls to legacy
  view classes that already mix these concerns.
- AppDelegate handles application lifecycle and top-level wiring only. Feature
  behavior belongs in the relevant MVC layer.
- Use the existing managers (`ProjectInfoManager`, `MainSettingsManager`) as the
  state entry points. Do not create parallel caches or new global mutable state.
  Prefer injected collaborators for new persistence/process work so it is testable.
- Keep one authoritative collection; derive filtered/sorted presentation data.
  Address projects/scripts by stable identity rather than row position across
  windows, menus, asynchronous callbacks, and filtered collections.
- Define notification ownership and timing. Publish consistent model state before
  notifying controllers; views update on the main thread. Release block observer
  tokens/event monitors and avoid retain cycles in callbacks.

## Swift and AppKit conventions

- Follow surrounding Swift style: four-space indentation, UpperCamelCase types,
  lowerCamelCase members, and `MARK` groups where useful. Match existing `VC`,
  `WC`, and `+Delegate`/`+DataSource` extension organization.
- Prefer `struct` for value data and `final class` for reference types that do not
  require inheritance. Use the narrowest practical access level and immutable
  values where possible. Avoid new `open` API in this application target.
- Use typed values and explicit error handling. Validate selections and collection
  bounds; do not force-unwrap user input, pasteboard content, files, or decoded data.
  Storyboard outlets may follow existing implicitly unwrapped outlet conventions.
- Preserve storyboard/XIB class names, identifiers, outlet/action connections, and
  target membership. Update project references when adding Swift/resources to this
  Xcode project; creating a file alone does not add it to the build.
- Keep AppKit work on the main thread. Run blocking discovery, network, file, and
  process operations off the UI thread, then return results safely for rendering.
  Honor the current Swift language mode instead of assuming Swift 6 APIs/settings.
- Capture `self` weakly in stored callbacks when needed. Match observer, timer,
  event monitor, task, and child-process lifetimes to their owners.
- Handle empty lists, missing projects/tools, cancelled panels, stale selections,
  malformed manifests, and unsupported data without crashing. Show actionable
  failures rather than silently swallowing errors or reporting false success.
- Preserve keyboard navigation, focus, labels, resizing, and macOS 13 API availability.

## Persistence, paths, and external commands

- Preserve existing plist filenames, coding keys, optional-field compatibility,
  project IDs, and custom-script data. Do not use real user settings as test fixtures.
- Persist the authoritative model, never only a search result. Keep list/menu
  projections consistent after add, remove, rename, sort, filter, and reorder.
- Prefer URL/path-component APIs for paths; use component-aware containment checks
  rather than string prefixes. Handle spaces, Unicode, quotes, and metacharacters.
- Prefer `Process.executableURL`, argument arrays, and `currentDirectoryURL` for
  direct tool execution. When Terminal/shell execution is required, escape data at
  both the shell and AppleScript boundaries. Treat deliberate custom commands as
  commands while keeping project paths and arguments as data.
- Respect the selected project and working directory. Do not launch terminal
  commands, clean folders, or change external projects while reviewing code.
- Never log secrets or include tokens, signing credentials, service-account keys,
  or private local data in source, tests, logs, or GitHub reports.
- Keep destructive operations within explicitly intended project paths and use
  the existing Trash behavior where applicable. Surface failures to the controller.
