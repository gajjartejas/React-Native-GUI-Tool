//
//  AppDelegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/03/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var projectListContexMenu: ProjectListStatusBarMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let projectInfos = ProjectInfoManager.shared.get(type: .menu)
        projectListContexMenu = ProjectListStatusBarMenu(projectInfos: projectInfos)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("applicationWillTerminate")
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        print("applicationSupportsSecureRestorableState")
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print("applicationDidBecomeActive")
        // NSApplication.shared.unhide(self)
    }

    func applicationDidHide(_ notification: Notification) {
        print("applicationDidHide")
        // NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("applicationShouldHandleReopen")
        let allWC = NSWindowController.getAllControllers()
        if let window = allWC.first?.window {
            window.makeKeyAndOrderFront(self)
        }
        return true
    }

    @IBAction func openSettings(_ sender: Any) {
        let allControllers = NSWindowController.getAllControllers()
        if let foundController = allControllers.compactMap({ $0 as? MainSettingsWC }).first {
            foundController.window?.makeKeyAndOrderFront(self)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateController(withIdentifier: "MainSettingsWC") as? MainSettingsWC else { return }
            if let mainWindow = allControllers.first?.window {
                controller.location = mainWindow.frame
            }
            controller.window?.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
