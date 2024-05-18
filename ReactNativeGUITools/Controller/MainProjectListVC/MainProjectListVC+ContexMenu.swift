//
//  MainProjectListVC+ContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 24/04/24.
//

import Cocoa

extension MainProjectListVC: NSMenuDelegate {
    func numberOfItems(in menu: NSMenu) -> Int {
        return contextMenu.numberOfItems
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = projectListTableView.clickedRow
        let col = projectListTableView.clickedColumn
        if row < 0 || col < 0 {
            return
        }
        // Update script
        contextMenu.removeItem(at: 9)

        let menu = initializeContexMenu(row: row).items[9]
        contextMenu.insertItem(menu, at: 9)
    }
}

extension MainProjectListVC {
    func initializeContexMenu(row: Int?) -> NSMenu {
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

        // Clean iOS
        let cleaniOSMenu = NSMenu()
        let cleaniOSMenuItem = NSMenuItem()
        cleaniOSMenu.addItem(NSMenuItem(title: "All", action: #selector(cleaniOSAllFolders(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "build", action: #selector(cleaniOSBuildFolder(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "Pods", action: #selector(cleaniOSPodsFolder(_:)), keyEquivalent: ""))
        cleaniOSMenuItem.submenu = cleaniOSMenu
        cleaniOSMenuItem.title = "Clean iOS"
        cleanMenu.addItem(cleaniOSMenuItem)

        // Clean Android
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

        return menu
    }

    // MARK: - Actions

    @objc func openAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateController(withIdentifier: "ToolsOutlineWC") as? ToolsOutlineWC else {
            return
        }
        controller.projectInfo = projectInfo
        controller.location = view.window?.frame
        controller.showWindow(self)
    }

    @objc func showInFinderAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        NSWorkspace.shared.selectFile(projectInfo.path, inFileViewerRootedAtPath: "")
    }

    @objc func openInTerminalAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        openTerminal(at: projectInfo.path)
    }

    @objc func renameAction(_ sender: Any?) {
        let selectedRow = projectListTableView.clickedRow
        if selectedRow != -1 {
            if let view = projectListTableView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? NSTableCellView {
                if let v = view as? ProjectListCellView {
                    v.projectNameLable.becomeFirstResponder()
                }
            }
        }
    }

    @objc func removeAction(_ sender: Any?) {
        if projectListTableView.clickedRow != -1 {
            projectInfoCollection.remove(at: projectListTableView.clickedRow)
            let indexSets = IndexSet(integer: projectListTableView.clickedRow)
            projectListTableView.removeRows(at: indexSets, withAnimation: .slideDown)
        }
    }

    @objc func runScript(_ sender: Any?) {
        guard let sender = sender as? NSMenuItem else {
            return
        }
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm run \(sender.title)"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func openInAndroidStudioAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        openAndroidStudio(atPath: projectInfo.path)
    }

    @objc func openInXcodeAction(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        openInXcode(atPath: projectInfo.path)
    }

    @objc func cleaniOSAllFolders(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/ios/build", "/ios/Pods"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniOSBuildFolder(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/ios/build"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniOSPodsFolder(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/ios/Pods"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidAllFolders(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/android/build", "/android/app/build", "/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidBuildFolder(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/android/build"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleaniAndroidAppBuildFolder(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/android/app/build"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAndroidAppReleaseFolder(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanAlliOSAllAndroid(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/ios/build", "/ios/Pods", "/android/build", "/android/app/build", "/android/app/release"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func cleanNodeModules(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let foldersToRemove = ["/node_modules"]
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        foldersToRemove.forEach { item in
            moveFolderToTrash(atPath: projectInfo.path + item)
        }
    }

    @objc func npmStart(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm start"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmInstall(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm install"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStartResetCache(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && start -- --reset-cache"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmRestart(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm restart"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmStop(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm stop"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheClean(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm cache clean"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func npmCacheVerify(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && npm cache verify"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatchDelAll(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && watchman watch-del-all"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanShutdownServer(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && watchman shutdown-server"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func watchmanWatch(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path) && watchman watch ."
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func metroReload(_ sender: Any?) {
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

    @objc func metroLaunchDevtools(_ sender: Any?) {
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

    @objc func metroDebug(_ sender: Any?) {
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

    @objc func metroViewiOSSource(_ sender: Any?) {
        let url = "http://localhost:8081/index.bundle?platform=ios&dev=true"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func metroViewAndroidSource(_ sender: Any?) {
        let url = "http://localhost:8081/index.bundle?platform=android&dev=true"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    @objc func podInstall(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod install"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podUpdate(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod update"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podOutdated(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod outdated"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podDeintegrate(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod deintegrate"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podEnv(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod env"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheList(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod cache list"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func podCacheCleanAll(_ sender: Any?) {
        if projectListTableView.clickedRow == -1 {
            return
        }
        let projectInfo = projectInfoCollection.projectInfos[projectListTableView.clickedRow]
        let script = "cd \(projectInfo.path)/ios && pod cache clean --all"
        openInTerminal(atPath: projectInfo.path, terminalScript: script)
    }

    @objc func customActionsEdit(_ sender: Any?) {}
}

func openTerminal(at path: String) {
    let terminalPath = "/usr/bin/open"
    let arguments = ["-a", "Terminal", path]

    let task = Process()
    task.executableURL = URL(fileURLWithPath: terminalPath)
    task.arguments = arguments

    do {
        try task.run()
    } catch {
        print("Error opening Terminal: \(error.localizedDescription)")
    }
}

func openAndroidStudio(atPath path: String) {
    let projectPath = path + "/android"
    let url = URL(fileURLWithPath: projectPath)
    let path = path + "/android"

    guard let appURL = FileManager.default.urls(
        for: .applicationDirectory,
        in: .localDomainMask
    ).first?.appendingPathComponent("Android Studio.app") else { return }

    // launch configuration
    let config = NSWorkspace.OpenConfiguration()
    config.addsToRecentItems = true
    config.createsNewApplicationInstance = false
    config.allowsRunningApplicationSubstitution = true
    config.activates = true
    config.arguments = [path]

    NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { app, error in
        if let error = error {
            print("unable to launch Preview.app: \(error.localizedDescription)")
            return
        }

        if let app = app {
            print("launched Preview.app with pid \(app.processIdentifier)")
        }
    }
}

func openInXcode(atPath path: String) {
    guard let xcodeProjectName = findXcodeProjectFile(atPath: path + "/ios") else { return }
    let projectPath = path + "/ios/\(xcodeProjectName)"
    let url = URL(fileURLWithPath: projectPath)

    guard let appURL = FileManager.default.urls(
        for: .applicationDirectory,
        in: .localDomainMask
    ).first?.appendingPathComponent("Xcode.app") else { return }

    // launch configuration
    let config = NSWorkspace.OpenConfiguration()
    config.addsToRecentItems = true
    config.createsNewApplicationInstance = false
    config.allowsRunningApplicationSubstitution = true
    config.activates = true
    config.arguments = [url.absoluteString]

    NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { app, error in
        if let error = error {
            print("unable to launch Preview.app: \(error.localizedDescription)")
            return
        }

        if let app = app {
            print("launched Preview.app with pid \(app.processIdentifier)")
        }
    }
}

func openInTerminal(atPath path: String, terminalScript: String) {
//    let url = URL(fileURLWithPath: path)
//    guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else { return }

    /* oneliner * /
     let AppleScriptSrc = "tell app \"Terminal\" to do script \"\(terminalScript)\""
     / **/
    /* or a script */
    let AppleScriptSrc = """
        tell app "Terminal"
            activate
            if number of windows > 0
                do script "\(terminalScript)" in tab 1 of window 1
            else
                do script "\(terminalScript)"
            end if
        end tell
    """
    /**/
    if let AppleScript = NSAppleScript(source: AppleScriptSrc) {
        var error: NSDictionary?
        AppleScript.executeAndReturnError(&error)
        if error != nil {
            print("Error: \(String(describing: error))")
        }
    }

//    let terminalScript = "echo hello"
//
//    let configuration = NSWorkspace.OpenConfiguration()
//    let doScriptEvent = NSAppleEventDescriptor(eventClass: kAECoreSuite,
//        eventID: kAEDoScript, targetDescriptor: nil, returnID: AEReturnID(kAutoGenerateReturnID),
//        transactionID: AETransactionID(kAnyTransactionID))
//    doScriptEvent.setParam(NSAppleEventDescriptor(string: terminalScript), forKeyword:keyDirectObject)
//    configuration.appleEvent = doScriptEvent
//    NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: { app, error in
//        if error != nil {
//            print("Error: \(String(describing: error))")
//        }
//    })

//    // launch configuration
//    let config = NSWorkspace.OpenConfiguration()
//    config.addsToRecentItems = true
//    config.createsNewApplicationInstance = false
//    config.allowsRunningApplicationSubstitution = true
//    config.activates = true
//    config.arguments = [terminalScript, url.path] // Include the command argument here
//
//    NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { app, error in
//        if let error = error {
//            print("unable to launch Preview.app: \(error.localizedDescription)")
//            return
//        }
//
//        if let app = app {
//            print("launched Preview.app with pid \(app.processIdentifier)")
//        }
//    }

//    let shellProcess =  Process();
//    shellProcess.launchPath = "/bin/bash";
//    shellProcess.arguments = [
//      "-l",
//      "-c",
//      // Important: this must all be one parameter to make it work.
//      "echo test",
//    ];
//    shellProcess.launch();
}

func moveFolderToTrash(atPath folderPath: String) {
    let fileManager = FileManager.default

    do {
        // Check if the folder exists
        if fileManager.fileExists(atPath: folderPath) {
            // Move the folder to the Trash
            try fileManager.trashItem(at: URL(fileURLWithPath: folderPath), resultingItemURL: nil)
            print("Folder moved to Trash successfully.")
        } else {
            print("Folder doesn't exist at the specified path.")
        }
    } catch {
        print("Error: \(error)")
    }
}
