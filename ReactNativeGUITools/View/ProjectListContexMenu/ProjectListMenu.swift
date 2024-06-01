//
//  ProjectListMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 22/05/24.
//

import Cocoa

protocol ProjectListMenuDelegate: AnyObject {
    func projectListMenuNeedsUpdate(_ menu: NSMenu)
    func projectListMenu(didSelectOpenMenuItem menuItem: NSMenuItem, at row: Int)
    func projectListMenu(didSelectRenameMenuItem menuItem: NSMenuItem, at row: Int)
    func projectListMenu(didSelectRemoveMenuItem menuItem: NSMenuItem, at row: Int)
}

extension ProjectListMenu: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.projectListMenuNeedsUpdate(menu)
    }
}

class ProjectListMenu: NSObject {
    var projectInfoCollection: ProjectInfoCollection!
    var clickedRow: Int?

    weak var delegate: ProjectListMenuDelegate?

    func setClickedRow(_ row: Int?) {
        clickedRow = row
    }

    func refreshMenu(_ menu: NSMenu) {
        guard let row = clickedRow else { return }
        menu.removeItem(at: 9)
        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        let scripts = projectInfoCollection.projectInfos[row].scripts
        if let scripts = scripts {
            let scriptMenu = NSMenu()
            for script in scripts {
                let scriptMenuSubItem = NSMenuItem()
                scriptMenuSubItem.title = script.name
                scriptMenuSubItem.action = #selector(runScript(_:))
                scriptMenuSubItem.target = self

                scriptMenu.addItem(scriptMenuSubItem)
            }
            scriptMenuItem.submenu = scriptMenu
        }
        menu.insertItem(scriptMenuItem, at: 9)
    }

    func createMenuFrom(from projectInfoCollection: ProjectInfoCollection, row: Int?) -> NSMenu {
        self.projectInfoCollection = projectInfoCollection
        clickedRow = row

        let menu = NSMenu()
        // Add menu items
        menu.addItem(withTitle: "Open", action: #selector(openAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Show in Finder", action: #selector(showInFinderAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Terminal", action: #selector(openInTerminalAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Android Studio", action: #selector(openInAndroidStudioAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Xcode", action: #selector(openInXcodeAction(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Rename", action: #selector(renameAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Remove", action: #selector(removeAction(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())
        
        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        if let row = row {
            let scripts = projectInfoCollection.projectInfos[row].scripts
            if let scripts = scripts {
                let scriptMenu = NSMenu()
                for script in scripts {
                    let scriptMenuSubItem = NSMenuItem()
                    scriptMenuSubItem.title = script.name
                    scriptMenuSubItem.action = #selector(runScript(_:))
                    scriptMenuSubItem.target = self

                    scriptMenu.addItem(scriptMenuSubItem)
                }
                scriptMenuItem.submenu = scriptMenu
                menu.addItem(scriptMenuItem)
            }
        } else {
            let scriptMenu = NSMenu()
            let scriptMenuSubItem = NSMenuItem()
            scriptMenuSubItem.title = "N/A"
            scriptMenuSubItem.action = #selector(runScript(_:))
            scriptMenuSubItem.isEnabled = false
            scriptMenu.addItem(scriptMenuSubItem)
            scriptMenuItem.submenu = scriptMenu
            menu.addItem(scriptMenuItem)
        }

        // Clean submenu
        let cleanMenu = NSMenu()
        let cleanMenuItem = NSMenuItem()
        cleanMenuItem.submenu = cleanMenu
        cleanMenuItem.title = "Clean"
        menu.addItem(cleanMenuItem)

        // Clean submenu -> Clean iOS
        let cleaniOSMenu = NSMenu()
        let cleaniOSMenuItem = NSMenuItem()
        cleaniOSMenu.addItem(NSMenuItem(title: "All", action: #selector(cleaniOSAllFolders(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "build", action: #selector(cleaniOSBuildFolder(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "Pods", action: #selector(cleaniOSPodsFolder(_:)), keyEquivalent: ""))
        cleaniOSMenuItem.submenu = cleaniOSMenu
        cleaniOSMenuItem.title = "Clean iOS"
        cleanMenu.addItem(cleaniOSMenuItem)

        // Clean submenu -> Clean Android
        let cleanAndroidMenu = NSMenu()
        let cleanAndroidMenuItem = NSMenuItem()
        cleanAndroidMenu.addItem(NSMenuItem(title: "All", action: #selector(cleanAndroidAllFolders(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "build", action: #selector(cleanAndroidBuildFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "app/build", action: #selector(cleanAndroidBuildFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "app/release", action: #selector(cleanAndroidAppReleaseFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenuItem.submenu = cleanAndroidMenu
        cleanAndroidMenuItem.title = "Clean Android"
        cleanMenu.addItem(cleanAndroidMenuItem)

        // Clean iOS & Android
        let cleaniOSAndroidMenuItem = NSMenuItem(title: "Clean iOS & Android", action: #selector(cleanAlliOSAllAndroid(_:)), keyEquivalent: "")
        cleanMenu.addItem(cleaniOSAndroidMenuItem)
        let cleanNodeModulesMenuItem = NSMenuItem(title: "Clean node_modules", action: #selector(cleanNodeModules(_:)), keyEquivalent: "")
        cleanMenu.addItem(cleanNodeModulesMenuItem)

        // NPM
        let npmSubMenu = NSMenu()
        npmSubMenu.addItem(withTitle: "start", action: #selector(npmStart(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "start -- --reset-cache", action: #selector(npmStartResetCache(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "restart", action: #selector(npmRestart(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "stop", action: #selector(npmStop(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "clean cache", action: #selector(npmCacheClean(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "cache verify", action: #selector(npmCacheVerify(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "install", action: #selector(npmInstall(_:)), keyEquivalent: "")

        let npmMenuItem = NSMenuItem()
        npmMenuItem.title = "NPM"
        npmMenuItem.submenu = npmSubMenu
        menu.addItem(npmMenuItem)

        // Watch menu
        let watchMenu = NSMenu()
        watchMenu.addItem(withTitle: "watch-del-all", action: #selector(watchmanWatchDelAll(_:)), keyEquivalent: "")
        watchMenu.addItem(withTitle: "shutdown-server", action: #selector(watchmanShutdownServer(_:)), keyEquivalent: "")
        watchMenu.addItem(withTitle: "watch", action: #selector(watchmanWatch(_:)), keyEquivalent: "")
        let watchmanMenuItem = NSMenuItem()
        watchmanMenuItem.title = "Watchman"
        watchmanMenuItem.submenu = watchMenu
        menu.addItem(watchmanMenuItem)

        // Metro
        let metroSubMenu = NSMenu()
        metroSubMenu.addItem(withTitle: "Reload", action: #selector(metroReload(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "Launch Devtools", action: #selector(metroLaunchDevtools(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "Debug", action: #selector(metroDebug(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "View iOS Source", action: #selector(metroViewiOSSource(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "View Anddroid Source", action: #selector(metroViewAndroidSource(_:)), keyEquivalent: "")
        let metroMenuItem = NSMenuItem()
        metroMenuItem.title = "Metro"
        metroMenuItem.submenu = metroSubMenu
        menu.addItem(metroMenuItem)

        // Pod
        let podSubMenu = NSMenu()
        podSubMenu.addItem(withTitle: "install", action: #selector(podInstall(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "update", action: #selector(podUpdate(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "outdated", action: #selector(podOutdated(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "deintegrate", action: #selector(podDeintegrate(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "env", action: #selector(podEnv(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "cache list", action: #selector(podCacheList(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "cache clean all", action: #selector(podCacheCleanAll(_:)), keyEquivalent: "")
        let podMenuItem = NSMenuItem()
        podMenuItem.title = "Pod"
        podMenuItem.submenu = podSubMenu
        menu.addItem(podMenuItem)

        // Custom Options
        let customSubMenu = NSMenu()
        customSubMenu.addItem(withTitle: "Edit...", action: #selector(customActionsEdit(_:)), keyEquivalent: "")
        let customActionMenuItem = NSMenuItem()
        customActionMenuItem.title = "Custom Action"
        customActionMenuItem.submenu = customSubMenu
        menu.addItem(customActionMenuItem)
        menu.setTargetToSelfRecursively(target: self)
        menu.delegate = self
        return menu
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
