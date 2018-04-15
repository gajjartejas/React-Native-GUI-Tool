//
//  CreateViewController.swift
//  React Native GUI
//
//  Created by Tejas on 15/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

class CreateViewController: NSViewController {

    var rnProjectName: String {
        get {
            return self.projectName.stringValue
        }
    }
    
    @IBOutlet weak var projectName: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func createProjectRNIClicked(_ sender: NSButton) {
        
        guard self.projectName.stringValue.count > 0 else {
            return
        }
        
        selectPath { (folderPath) in
            
            let script = "tell application \"Terminal\" to do script \"cd \'\(folderPath)\'\nreact-native init \(self.rnProjectName)\""
            
            let aplsc = NSAppleScript.init(source: script)
            
            aplsc?.executeAndReturnError(nil)
        }

    }
    
    @IBAction func createProjectCRNAClicked(_ sender: NSButton) {
        
        guard self.projectName.stringValue.count > 0 else {
            return
        }
        
        selectPath { (folderPath) in
            
            let script = "tell application \"Terminal\" to do script \"cd \'\(folderPath)\'\ncreate-react-native-app \(self.rnProjectName)\""
            
            let aplsc = NSAppleScript.init(source: script)
            
            aplsc?.executeAndReturnError(nil)
        }
        
    }
    
    func selectPath(path: @escaping (String)->()) {
        let openPanel = NSOpenPanel();
        openPanel.title = "Select a folder to watch for videos"
        openPanel.message = "Videos you drop in the folder you select will be converted to animated gifs"
        openPanel.showsResizeIndicator=true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        
        openPanel.begin { (result) -> Void in
            if(result.rawValue == NSApplication.ModalResponse.OK.rawValue){
                let folderPath = openPanel.url!.path
                
                print("filePath",folderPath)
                
                path(folderPath)
                
                
            }
        }
    }
    
}
