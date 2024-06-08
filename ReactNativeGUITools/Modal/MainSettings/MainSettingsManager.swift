//
//  MainSettingsManager.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 08/06/24.
//

import Foundation

class MainSettingsManager {
    struct NotificationNames {
        static let mainSettingsDidChange = Notification.Name("mainSettingsDidChange")
    }

    static let shared = MainSettingsManager()

    open var mainSettings: MainSettings {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.mainSettingsDidChange, object: nil)
        }
    }

    private init() {
        guard let storedSettings = MainSettings.readFromStorage() else {
            mainSettings = MainSettings()
            return
        }

        mainSettings = storedSettings
    }

    func setDefaultCodeEditor(item: PathVersion) {
        mainSettings.defaultCodeEditor = item
        _ = MainSettings.writeToStorage(mainSettings)
    }

    func setDefaultXcodePath(item: PathVersion) {
        mainSettings.defaultXcodePath = item
        _ = MainSettings.writeToStorage(mainSettings)
    }

    func setDefaultAndroidStudio(item: PathVersion) {
        mainSettings.defaultAndroidStudio = item
        _ = MainSettings.writeToStorage(mainSettings)
    }
}
