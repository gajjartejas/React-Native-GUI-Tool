//
//  ProjectListMenuController+Actions.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

extension ProjectListMenuController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.projectListMenuNeedsUpdate(menu)
    }
}

extension ProjectListMenuController {
    // MARK: - Actions

    @objc func openAction(_ sender: NSMenuItem) {
        guard let row = clickedRow else { return }
        delegate?.projectListMenu(didSelectOpenMenuItem: sender, at: row)
    }

    @objc func showInFinderAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: projectInfo.path)
    }

    @objc func openInTerminalAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        openTerminal(at: projectInfo.path)
    }

    @objc func copyPathAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(projectInfo.path, forType: .string)
    }

    @objc func renameAction(_ sender: NSMenuItem) {
        guard let row = clickedRow else { return }
        delegate?.projectListMenu(didSelectRenameMenuItem: sender, at: row)
    }

    @objc func removeAction(_ sender: NSMenuItem) {
        guard let row = clickedRow else { return }
        delegate?.projectListMenu(didSelectRemoveMenuItem: sender, at: row)
    }

    @objc func runScript(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.runScript(sender.title))
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func openInCodeEditorAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        guard let defaultCodeEditor = MainSettingsManager.shared.mainSettings.defaultCodeEditor else { return }
        launchApplication(at: projectInfo.path, using: defaultCodeEditor)
    }

    @objc func openInAndroidStudioAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        guard let defaultAndroidStudio = MainSettingsManager.shared.mainSettings.defaultAndroidStudio else { return }
        launchApplication(at: projectInfo.path + "/android", using: defaultAndroidStudio)
    }

    @objc func openInXcodeAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        guard let defaultXcode = MainSettingsManager.shared.mainSettings.defaultXcodePath else { return }
        let path = projectInfo.path + "/ios"
        guard let xcodeProjectName = findXcodeProjectFile(atPath: path) else { return }
        launchApplication(at: path + "/\(xcodeProjectName)", using: defaultXcode)
    }

    @objc func cleaniOSAllFolders(_ sender: NSMenuItem) {
        trashFolders(.cleaniOSAllFolders)
    }

    @objc func cleaniOSBuildFolder(_ sender: NSMenuItem) {
        trashFolders(.cleaniOSBuildFolder)
    }

    @objc func cleaniOSPodsFolder(_ sender: NSMenuItem) {
        trashFolders(.cleaniOSPodsFolder)
    }

    @objc func cleanAndroidAllFolders(_ sender: NSMenuItem) {
        trashFolders(.cleanAndroidAllFolders)
    }

    @objc func cleanAndroidBuildFolder(_ sender: NSMenuItem) {
        trashFolders(.cleanAndroidBuildFolder)
    }

    @objc func cleanAndroidAppBuildFolder(_ sender: NSMenuItem) {
        trashFolders(.cleanAndroidAppBuildFolder)
    }

    @objc func cleanAndroidAppReleaseFolder(_ sender: NSMenuItem) {
        trashFolders(.cleanAndroidAppReleaseFolder)
    }

    @objc func cleanAlliOSAllAndroid(_ sender: NSMenuItem) {
        trashFolders(.cleanAlliOSAllAndroid)
    }

    @objc func cleanNodeModules(_ sender: NSMenuItem) {
        trashFolders(.cleanNodeModules)
    }

    private func trashFolders(_ target: ProjectInfo.CleanupTarget) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }
        projectInfo.cleanupPaths(for: target).forEach(trashFolder)
    }

    @objc func npmStart(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmStart)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmInstall(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmInstall)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStartResetCache(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmStartResetCache)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmRestart(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmRestart)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStop(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmStop)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheClean(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmCacheClean)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheVerify(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.npmCacheVerify)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatchDelAll(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.watchmanWatchDelAll)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanShutdownServer(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.watchmanShutdownServer)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatch(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.watchmanWatch)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func metroReload(_ sender: NSMenuItem) {
        let url = "http://localhost:8081/reload"
        guard let url = URL(string: url) else { return }
        URLSession.shared.get(url) { result in
            switch result {
            case let .success(data):
                if let dataString = String(data: data, encoding: .utf8) {
                    print("metroReload: \(dataString)")
                }
            case let .failure(error):
                print("metroReload: \(error)")
            }
        }
    }

    @objc func metroLaunchDevtools(_ sender: NSMenuItem) {
        let url = "http://localhost:8081/launch-js-devtools"
        guard let url = URL(string: url) else { return }
        URLSession.shared.get(url) { result in
            switch result {
            case let .success(data):
                if let dataString = String(data: data, encoding: .utf8) {
                    print("metroLaunchDevtools: \(dataString)")
                }
            case let .failure(error):
                print("metroLaunchDevtools: \(error)")
            }
        }
    }

    @objc func metroDebug(_ sender: NSMenuItem) {
        let url = "http://localhost:8081/debug"
        guard let url = URL(string: url) else { return }
        URLSession.shared.get(url) { result in
            switch result {
            case let .success(data):
                if let dataString = String(data: data, encoding: .utf8) {
                    print("metroDebug: \(dataString)")
                }
            case let .failure(error):
                print("metroDebug: \(error)")
            }
        }
    }

    @objc func metroViewiOSSource(_ sender: NSMenuItem) {
        let url = "http://localhost:8081/index.bundle?platform=ios&dev=true"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func metroViewAndroidSource(_ sender: NSMenuItem) {
        let url = "http://localhost:8081/index.bundle?platform=android&dev=true"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func podInstall(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podInstall)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podUpdate(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podUpdate)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podOutdated(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podOutdated)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podDeintegrate(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podDeintegrate)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podEnv(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podEnv)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheList(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podCacheList)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheCleanAll(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = projectInfo.terminalCommand(.podCacheCleanAll)
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func runCustomActionScript(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }

        let selectedScript: ProjectInfo.CustomMenuScript
        if let customScript = sender.representedObject as? ProjectInfo.CustomMenuScript {
            selectedScript = customScript
        } else if let found = projectInfo.customMenuScripts?.first(where: { $0.name == sender.title }) {
            selectedScript = found
        } else {
            return
        }

        let terminalScript = projectInfo.terminalCommand(selectedScript.isFileScript ? .customFile(selectedScript.script) : .custom(selectedScript.script))
        openInTerminal(atPath: projectInfo.path, terminalScript: terminalScript)
    }

    @objc func customActionsEdit(_ sender: NSMenuItem) {
        guard let row = clickedRow, projectInfos.indices.contains(row) else { return }
        let projectInfo = projectInfos[row]
        guard FileManager.default.fileExists(atPath: projectInfo.path) else { return }

        ToolsOutlineWC.show(project: projectInfo, selectingTab: 12)
    }
}
