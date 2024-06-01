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

class ProjectListMenu: NSObject {
    var projectInfoCollection: ProjectInfoCollection!
    var clickedRow: Int?

    weak var delegate: ProjectListMenuDelegate?

    func setClickedRow(_ row: Int?) {
        clickedRow = row
    }

    func refreshMenu(_ menu: NSMenu) {
        guard let row = clickedRow else { return }
        menu.removeItem(at: 10)
        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        let scripts = projectInfoCollection.projectInfos[row].scripts?.sorted(by: customSort)
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
        menu.insertItem(scriptMenuItem, at: 10)
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

        menu.addItem(withTitle: "Copy Path", action: #selector(copyPathAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Rename", action: #selector(renameAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Remove", action: #selector(removeAction(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())
        
        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        if let row = row {
            let scripts = projectInfoCollection.projectInfos[row].scripts?.sorted(by: customSort)

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

