//
//  MainProjectListVC+ContexMenu.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 24/04/24.
//

import Cocoa

extension MainProjectListVC {
    func initializeContexMenu() -> NSMenu {
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

        let scriptSubMenu = NSMenu()
        scriptSubMenu.addItem(withTitle: "Show All Package JSON Scripts", action: #selector(showAllPackageScripts(_:)), keyEquivalent: "")
        let scriptMenuItem = NSMenuItem()
        scriptMenuItem.title = "Script"
        scriptMenuItem.submenu = scriptSubMenu
        menu.addItem(scriptMenuItem)

        let runSubMenu = NSMenu()
        runSubMenu.addItem(withTitle: "Run npm install", action: #selector(runNpmInstall(_:)), keyEquivalent: "")
        runSubMenu.addItem(withTitle: "Run pod install", action: #selector(runPodInstall(_:)), keyEquivalent: "")
        runSubMenu.addItem(withTitle: "Run yarn install", action: #selector(runYarnInstall(_:)), keyEquivalent: "")
        let runMenuItem = NSMenuItem()
        runMenuItem.title = "Run"
        runMenuItem.submenu = runSubMenu
        menu.addItem(runMenuItem)

        // Create Clean submenu
        let cleanSubMenu = NSMenu()
        let cleaniOSMenuItem = NSMenuItem()
        cleaniOSMenuItem.title = "Clean iOS"
        let cleaniOSBuildFolderItem = NSMenuItem(title: "Build Folder", action: #selector(cleaniOSBuildFolder(_:)), keyEquivalent: "")
        let cleaniOSPodItem = NSMenuItem(title: "Pod", action: #selector(cleaniOSPod(_:)), keyEquivalent: "")
        cleanSubMenu.addItem(cleaniOSBuildFolderItem)
        cleanSubMenu.addItem(cleaniOSPodItem)
        cleaniOSMenuItem.submenu = cleanSubMenu

        let cleanAndroidMenuItem = NSMenuItem()
        cleanAndroidMenuItem.title = "Clean Android"
        let cleanAndroidBuildFolderItem = NSMenuItem(title: "Build Folder", action: #selector(cleanAndroidBuildFolder(_:)), keyEquivalent: "")
        let cleanAndroidReleaseItem = NSMenuItem(title: "Release", action: #selector(cleanAndroidRelease(_:)), keyEquivalent: "")
        cleanSubMenu.addItem(cleanAndroidBuildFolderItem)
        cleanSubMenu.addItem(cleanAndroidReleaseItem)
        cleanAndroidMenuItem.submenu = cleanSubMenu

        menu.addItem(cleaniOSMenuItem)
        menu.addItem(cleanAndroidMenuItem)

        let npmSubMenu = NSMenu()
        npmSubMenu.addItem(withTitle: "Remove node_modules", action: #selector(removeNodeModules(_:)), keyEquivalent: "")
        npmSubMenu.addItem(withTitle: "Clear npm cache", action: #selector(clearNpmCache(_:)), keyEquivalent: "")
        let npmMenuItem = NSMenuItem()
        npmMenuItem.title = "NPM"
        npmMenuItem.submenu = npmSubMenu
        menu.addItem(npmMenuItem)

        let metroSubMenu = NSMenu()
        metroSubMenu.addItem(withTitle: "Reload", action: #selector(reloadMetro(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "Debug", action: #selector(debugMetro(_:)), keyEquivalent: "")
        metroSubMenu.addItem(withTitle: "View Source", action: #selector(viewSourceMetro(_:)), keyEquivalent: "")
        let metroMenuItem = NSMenuItem()
        metroMenuItem.title = "Metro"
        metroMenuItem.submenu = metroSubMenu
        menu.addItem(metroMenuItem)

        let apkToolSubMenu = NSMenu()
        apkToolSubMenu.addItem(withTitle: "Export APK", action: #selector(exportAPK(_:)), keyEquivalent: "")
        apkToolSubMenu.addItem(withTitle: "AAB to APK", action: #selector(aabToApk(_:)), keyEquivalent: "")
        let apkToolMenuItem = NSMenuItem()
        apkToolMenuItem.title = "Apk Tool"
        apkToolMenuItem.submenu = apkToolSubMenu
        menu.addItem(apkToolMenuItem)

        let customSubMenu = NSMenu()
        customSubMenu.addItem(withTitle: "Edit...", action: #selector(exportAPK(_:)), keyEquivalent: "")
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
        controller.showWindow(self)
    }

    @objc func showInFinderAction(_ sender: Any?) {}
    @objc func openInTerminalAction(_ sender: Any?) {}
    @objc func renameAction(_ sender: Any?) {}
    @objc func showAllPackageScripts(_ sender: Any?) {}
    @objc func openInAndroidStudioAction(_ sender: Any?) {}
    @objc func openInXcodeAction(_ sender: Any?) {}
    @objc func runNpmInstall(_ sender: Any?) {}
    @objc func runPodInstall(_ sender: Any?) {}
    @objc func runYarnInstall(_ sender: Any?) {}
    @objc func cleaniOSBuildFolder(_ sender: Any?) {}
    @objc func cleaniOSPod(_ sender: Any?) {}
    @objc func cleanAndroidBuildFolder(_ sender: Any?) {}
    @objc func cleanAndroidRelease(_ sender: Any?) {}
    @objc func removeNodeModules(_ sender: Any?) {}
    @objc func clearNpmCache(_ sender: Any?) {}
    @objc func renameProject(_ sender: Any?) {}
    @objc func reloadMetro(_ sender: Any?) {}
    @objc func debugMetro(_ sender: Any?) {}
    @objc func viewSourceMetro(_ sender: Any?) {}
    @objc func exportAPK(_ sender: Any?) {}
    @objc func aabToApk(_ sender: Any?) {}
    @objc func customActions(_ sender: Any?) {}

    @objc func removeAction(_ sender: Any?) {
        if projectListTableView.clickedRow != -1 {
            projectInfoCollection.remove(at: projectListTableView.clickedRow)
            let indexSets = IndexSet(integer: projectListTableView.clickedRow)
            projectListTableView.removeRows(at: indexSets, withAnimation: .slideDown)
        }
    }

    @objc func editAction(_ sender: Any?) {
    }
}
