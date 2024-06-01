//
//  ProjectListMenu+Extension.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/06/24.
//

import Cocoa

extension ProjectListMenu {
    func customSort(_ lhs: (name: String, value: String), _ rhs: (name: String, value: String)) -> Bool {
        let customOrder = ["start", "test", "lint", "android", "ios"]

        let lhsIndex = customOrder.firstIndex(of: lhs.name) ?? Int.max
        let rhsIndex = customOrder.firstIndex(of: rhs.name) ?? Int.max

        if lhsIndex != rhsIndex {
            return lhsIndex < rhsIndex
        } else {
            return lhs.name > rhs.name
        }
    }
}

extension ProjectListMenu: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.projectListMenuNeedsUpdate(menu)
    }
}

extension ProjectListMenu {
    // MARK: - Actions

    @objc func openAction(_ sender: NSMenuItem) {
        guard let row = clickedRow else { return }
        delegate?.projectListMenu(didSelectOpenMenuItem: sender, at: row)
    }

    @objc func showInFinderAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: projectInfo.path)
    }

    @objc func openInTerminalAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        openTerminal(at: projectInfo.path)
    }

    @objc func copyPathAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
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
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm run \(sender.title)"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func openInAndroidStudioAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        openAndroidStudio(atPath: projectInfo.path)
    }

    @objc func openInXcodeAction(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        openInXcode(atPath: projectInfo.path)
    }

    @objc func cleaniOSAllFolders(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/ios/build", "/ios/Pods"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniOSBuildFolder(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/ios/build"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniOSPodsFolder(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/ios/Pods"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidAllFolders(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/android/build", "/android/app/build", "/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidBuildFolder(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/android/build"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniAndroidAppBuildFolder(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/android/app/build"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidAppReleaseFolder(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAlliOSAllAndroid(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/ios/build", "/ios/Pods", "/android/build", "/android/app/build", "/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanNodeModules(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let foldersToRemove = ["/node_modules"]
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func npmStart(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm start"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmInstall(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm install"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStartResetCache(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && start -- --reset-cache"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmRestart(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm restart"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStop(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm stop"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheClean(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm cache clean"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheVerify(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && npm cache verify"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatchDelAll(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && watchman watch-del-all"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanShutdownServer(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && watchman shutdown-server"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatch(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path) && watchman watch ."
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
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod install"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podUpdate(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod update"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podOutdated(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod outdated"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podDeintegrate(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod deintegrate"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podEnv(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod env"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheList(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod cache list"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheCleanAll(_ sender: NSMenuItem) {
        guard let clickedRow = clickedRow else { return }
        let projectInfo = projectInfoCollection.projectInfos[clickedRow]
        let fileExists = FileManager.default.fileExists(atPath: projectInfo.path)
        if !fileExists {
            return
        }
        let script = "cd \(projectInfo.path)/ios && pod cache clean --all"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func customActionsEdit(_ sender: NSMenuItem) {}
}
