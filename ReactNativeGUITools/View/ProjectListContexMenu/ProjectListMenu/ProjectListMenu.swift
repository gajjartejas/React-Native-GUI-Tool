//
//  ProjectListMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 22/05/24.
//

import Cocoa

/// Renders supplied project data; actions are handled by its controller.
final class ProjectListMenu {
    func refreshMenu(_ menu: NSMenu, project: ProjectInfo, target: ProjectListMenuController) {
        if let scriptIndex = menu.items.firstIndex(where: { $0.title == "Script" }) {
            menu.removeItem(at: scriptIndex)
            let scriptMenuItem = NSMenuItem()
            scriptMenuItem.title = "Script"
            let scripts = project.orderedPackageJsonScripts
            if let scripts = scripts {
                let scriptMenu = NSMenu()
                for script in scripts {
                    let scriptMenuSubItem = NSMenuItem()
                    scriptMenuSubItem.title = script.name
                    scriptMenuSubItem.action = #selector(ProjectListMenuController.runScript(_:))
                    scriptMenuSubItem.target = target

                    scriptMenu.addItem(scriptMenuSubItem)
                }
                scriptMenuItem.submenu = scriptMenu
            }
            menu.insertItem(scriptMenuItem, at: scriptIndex)
        }

        if let customActionIndex = menu.items.firstIndex(where: { $0.title == "Custom Actions" }) {
            menu.removeItem(at: customActionIndex)
            let customSubMenu = NSMenu()
            if let customScripts = project.customMenuScripts, !customScripts.isEmpty {
                for customScript in customScripts {
                    let item = NSMenuItem(title: customScript.name, action: #selector(ProjectListMenuController.runCustomActionScript(_:)), keyEquivalent: "")
                    item.representedObject = customScript
                    item.target = target
                    customSubMenu.addItem(item)
                }
                customSubMenu.addItem(NSMenuItem.separator())
            }
            let editItem = NSMenuItem(title: "Edit...", action: #selector(ProjectListMenuController.customActionsEdit(_:)), keyEquivalent: "")
            editItem.target = target
            customSubMenu.addItem(editItem)
            let customActionMenuItem = NSMenuItem()
            customActionMenuItem.title = "Custom Actions"
            customActionMenuItem.submenu = customSubMenu
            menu.insertItem(customActionMenuItem, at: customActionIndex)
        }
    }

    func createMenuFrom(projectInfos: [ProjectInfo], row: Int?, target: ProjectListMenuController) -> NSMenu {

        let menu = NSMenu()
        // Add menu items
        menu.addItem(withTitle: "Open", action: #selector(ProjectListMenuController.openAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Show in Finder", action: #selector(ProjectListMenuController.showInFinderAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Terminal", action: #selector(ProjectListMenuController.openInTerminalAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Code Editor", action: #selector(ProjectListMenuController.openInCodeEditorAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Android Studio", action: #selector(ProjectListMenuController.openInAndroidStudioAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Open in Xcode", action: #selector(ProjectListMenuController.openInXcodeAction(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Copy Path", action: #selector(ProjectListMenuController.copyPathAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Rename", action: #selector(ProjectListMenuController.renameAction(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Remove", action: #selector(ProjectListMenuController.removeAction(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        if let row = row {
            scriptMenuItem.isEnabled = true
            let scripts = projectInfos[row].orderedPackageJsonScripts

            if let scripts = scripts {
                let scriptMenu = NSMenu()
                for script in scripts {
                    let scriptMenuSubItem = NSMenuItem()
                    scriptMenuSubItem.title = script.name
                    scriptMenuSubItem.action = #selector(ProjectListMenuController.runScript(_:))
                    scriptMenuSubItem.target = target
                    scriptMenu.addItem(scriptMenuSubItem)
                }
                scriptMenuItem.submenu = scriptMenu
                menu.addItem(scriptMenuItem)
            }
        } else {
            menu.addItem(scriptMenuItem)
            scriptMenuItem.isEnabled = false
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
        cleaniOSMenu.addItem(NSMenuItem(title: "All", action: #selector(ProjectListMenuController.cleaniOSAllFolders(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "build", action: #selector(ProjectListMenuController.cleaniOSBuildFolder(_:)), keyEquivalent: ""))
        cleaniOSMenu.addItem(NSMenuItem(title: "Pods", action: #selector(ProjectListMenuController.cleaniOSPodsFolder(_:)), keyEquivalent: ""))
        cleaniOSMenuItem.submenu = cleaniOSMenu
        cleaniOSMenuItem.title = "Clean iOS"
        cleanMenu.addItem(cleaniOSMenuItem)

        // Clean submenu -> Clean Android
        let cleanAndroidMenu = NSMenu()
        let cleanAndroidMenuItem = NSMenuItem()
        cleanAndroidMenu.addItem(NSMenuItem(title: "All", action: #selector(ProjectListMenuController.cleanAndroidAllFolders(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "build", action: #selector(ProjectListMenuController.cleanAndroidBuildFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "app/build", action: #selector(ProjectListMenuController.cleanAndroidAppBuildFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenu.addItem(NSMenuItem(title: "app/release", action: #selector(ProjectListMenuController.cleanAndroidAppReleaseFolder(_:)), keyEquivalent: ""))
        cleanAndroidMenuItem.submenu = cleanAndroidMenu
        cleanAndroidMenuItem.title = "Clean Android"
        cleanMenu.addItem(cleanAndroidMenuItem)

        // Clean iOS & Android
        let cleaniOSAndroidMenuItem = NSMenuItem(title: "Clean iOS & Android", action: #selector(ProjectListMenuController.cleanAlliOSAllAndroid(_:)), keyEquivalent: "")
        cleanMenu.addItem(cleaniOSAndroidMenuItem)
        let cleanNodeModulesMenuItem = NSMenuItem(title: "Clean node_modules", action: #selector(ProjectListMenuController.cleanNodeModules(_:)), keyEquivalent: "")
        cleanMenu.addItem(cleanNodeModulesMenuItem)

        // NPM
        let npmSubMenu = NSMenu()
        npmSubMenu.addItem(withTitle: "start", action: #selector(ProjectListMenuController.npmStart(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "start -- --reset-cache", action: #selector(ProjectListMenuController.npmStartResetCache(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "restart", action: #selector(ProjectListMenuController.npmRestart(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "stop", action: #selector(ProjectListMenuController.npmStop(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "clean cache", action: #selector(ProjectListMenuController.npmCacheClean(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "cache verify", action: #selector(ProjectListMenuController.npmCacheVerify(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "install", action: #selector(ProjectListMenuController.npmInstall(_:)), keyEquivalent: "")

        let npmMenuItem = NSMenuItem()
        npmMenuItem.title = "NPM"
        npmMenuItem.submenu = npmSubMenu
        menu.addItem(npmMenuItem)

        // Watch menu
        let watchMenu = NSMenu()
        watchMenu.addItem(withTitle: "watch-del-all", action: #selector(ProjectListMenuController.watchmanWatchDelAll(_:)), keyEquivalent: "")
        watchMenu.addItem(withTitle: "shutdown-server", action: #selector(ProjectListMenuController.watchmanShutdownServer(_:)), keyEquivalent: "")
        watchMenu.addItem(withTitle: "watch", action: #selector(ProjectListMenuController.watchmanWatch(_:)), keyEquivalent: "")
        let watchmanMenuItem = NSMenuItem()
        watchmanMenuItem.title = "Watchman"
        watchmanMenuItem.submenu = watchMenu
        menu.addItem(watchmanMenuItem)

        // Metro
        let metroSubMenu = NSMenu()
        metroSubMenu.addItem(withTitle: "Reload", action: #selector(ProjectListMenuController.metroReload(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "Launch Devtools", action: #selector(ProjectListMenuController.metroLaunchDevtools(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "Debug", action: #selector(ProjectListMenuController.metroDebug(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "View iOS Source", action: #selector(ProjectListMenuController.metroViewiOSSource(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "View Android Source", action: #selector(ProjectListMenuController.metroViewAndroidSource(_:)), keyEquivalent: "")
        let metroMenuItem = NSMenuItem()
        metroMenuItem.title = "Metro"
        metroMenuItem.submenu = metroSubMenu
        menu.addItem(metroMenuItem)

        // Pod
        let podSubMenu = NSMenu()
        podSubMenu.addItem(withTitle: "install", action: #selector(ProjectListMenuController.podInstall(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "update", action: #selector(ProjectListMenuController.podUpdate(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "outdated", action: #selector(ProjectListMenuController.podOutdated(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "deintegrate", action: #selector(ProjectListMenuController.podDeintegrate(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "env", action: #selector(ProjectListMenuController.podEnv(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "cache list", action: #selector(ProjectListMenuController.podCacheList(_:)), keyEquivalent: "")
        podSubMenu.addItem(withTitle: "cache clean all", action: #selector(ProjectListMenuController.podCacheCleanAll(_:)), keyEquivalent: "")
        let podMenuItem = NSMenuItem()
        podMenuItem.title = "Pod"
        podMenuItem.submenu = podSubMenu
        menu.addItem(podMenuItem)

        // Custom Options
        let customSubMenu = NSMenu()
        if let row = row, let customScripts = projectInfos[row].customMenuScripts, !customScripts.isEmpty {
            for customScript in customScripts {
                let item = NSMenuItem(title: customScript.name, action: #selector(ProjectListMenuController.runCustomActionScript(_:)), keyEquivalent: "")
                item.representedObject = customScript
                item.target = target
                customSubMenu.addItem(item)
            }
            customSubMenu.addItem(NSMenuItem.separator())
        }
        let editItem = NSMenuItem(title: "Edit...", action: #selector(ProjectListMenuController.customActionsEdit(_:)), keyEquivalent: "")
        editItem.target = target
        customSubMenu.addItem(editItem)
        let customActionMenuItem = NSMenuItem()
        customActionMenuItem.title = "Custom Actions"
        customActionMenuItem.submenu = customSubMenu
        menu.addItem(customActionMenuItem)
        menu.setTargetToSelfRecursively(target: target)
        menu.delegate = target
        return menu
    }
}
