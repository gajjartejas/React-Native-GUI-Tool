//
//  AppExtensions.swift
//  React Native GUI
//
//  Created by Tejas on 07/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

extension String {
    func run() -> String? {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["bash", "-c", self]
        process.standardOutput = pipe
        
        let fileHandle = pipe.fileHandleForReading
        process.launch()
        
        return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
    }
}

extension NSAlert {
    
    static func showAlert(title: String?, message: String?, style: NSAlert.Style = .informational) {
        let alert = NSAlert()
        if let title = title {
            alert.messageText = title
        }
        if let message = message {
            alert.informativeText = message
        }
        alert.alertStyle = style
        alert.runModal()
    }
    
}
