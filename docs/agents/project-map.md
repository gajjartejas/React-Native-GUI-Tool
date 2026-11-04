# Project map

Paths below are relative to `ReactNativeGUITools/`. Use this map to narrow searches;
read only the relevant files and their direct collaborators. Verify current source
before editing; update affected entries when moving ownership or files.

| Feature | Start here | Direct collaborators |
| --- | --- | --- |
| Project list/search/drop | `Controller/MainProjectListVC/` | `Modal/ProjectInfo/ProjectInfoManager.swift`, `View/ProjectListCellView/`, `View/DropView.swift` |
| Context menus/actions | `Controller/ProjectListMenuController/` | `View/ProjectListContexMenu/ProjectListMenu/ProjectListMenu.swift`, `Modal/ProjectInfo/ProjectInfo+Commands.swift`, `Utils/AppUtils.swift` |
| Status menu | `Controller/ProjectListStatusBarMenuController/` | `AppDelegate.swift`, context-menu controller, project manager |
| Custom actions | `Controller/CustomActionsVC/`, `Controller/AddCustomActionVC/` | `Modal/ProjectInfo/CustomMenuScript.swift`, `ProjectInfo+CustomActions.swift` in the same model folder |
| Project metadata/order | `Modal/ProjectInfo/` | `PackageManifestReader.swift`, `ProjectOrdering.swift`, `ProjectInfo.swift`, project manager |
| Settings/tool discovery | `Controller/MainSettingsVC/` | `Modal/MainSettings/`, `Controller/MainSettingsWC.swift` |
| Project windows/navigation | `Controller/ToolsOutlineWC.swift`, `Controller/ToolsOutlineVC/` | `Controller/ProjectTabViewController/`, `Modal/MenuNode.swift` |
| Individual tools | Matching feature folder in `Controller/` | Many modules are placeholders; inspect the implementation before claiming support |
| UI resources | `Base.lproj/Main.storyboard`, `View/**/*.xib`, `Assets.xcassets/` | Search identifiers/connections before reading large resource files |
| Persistence | `Extensions/PlistStorable.swift` | `Modal/ProjectInfo/`, `Modal/MainSettings/`; preserve existing coding keys |

Root-level tooling:

- `ReactNativeGUITools.xcodeproj/project.pbxproj`: file membership/build settings;
  inspect relevant entries rather than the entire file.
- `scripts/test_mvc.py`: dependency checks and standalone Swift regression runner.
- `Tests/MVCRegressionTests.swift`: model, persistence, menu, and cell checks.
- [Validation commands](validation.md) and [issue workflow](github.md): load only
  for the corresponding work. Read full GitHub findings live when needed; this map
  intentionally does not cache changing issue status.
