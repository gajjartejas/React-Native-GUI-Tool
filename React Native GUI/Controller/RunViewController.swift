//
//  ViewController.swift
//  Generate Bundle - React native
//
//  Created by Tejas on 31/03/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

class RunViewController: NSViewController {
    
    var folderPath: String?
    var indexJSAndroidPath: String?
    var indexJSiOSPath: String?
    
    @IBOutlet weak var rnIndexJSAndroidPath: NSTextField!
    @IBOutlet weak var rnIndexJSiOSPath: NSTextField!
    
    @IBOutlet weak var rnFolderPath: NSTextField!
    @IBOutlet weak var dropView: DropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropView.dragging { (folderPath) in
            
            print("filePath",folderPath)
            
            self.folderPath = folderPath
            
            self.rnFolderPath.stringValue = folderPath
            
            self.validateIndexJSFile()
        }
        
        dropView.leftClick {
            let openPanel = NSOpenPanel();
            openPanel.title = "Select a folder to watch for videos"
            openPanel.message = "Videos you drop in the folder you select will be converted to animated gifs"
            openPanel.showsResizeIndicator=true
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.allowsMultipleSelection = false
            openPanel.canCreateDirectories = true
            
            if let folderPath = self.folderPath {
                openPanel.directoryURL = URL.init(string: folderPath)
            }
            
            openPanel.begin { (result) -> Void in
                if(result.rawValue == NSApplication.ModalResponse.OK.rawValue){
                    let folderPath = openPanel.url!.path
                    
                    print("filePath",folderPath)
                    
                    self.folderPath = folderPath
                    
                    self.rnFolderPath.stringValue = folderPath
                    
                    self.validateIndexJSFile()
                    
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func rnFolderClicked(_ sender: NSButton) {
        
        guard let folderPath = self.folderPath else {
            return
        }
        
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderPath)
    }
    
    @IBAction func rnIndexJsAndroidClicked(_ sender: NSButton) {
        
        guard let folderPath = self.indexJSAndroidPath else {
            return
        }
        
        NSWorkspace.shared.selectFile(folderPath, inFileViewerRootedAtPath: "")
    }
    
    @IBAction func rnIndexJsiOSClicked(_ sender: NSButton) {
        
        guard let folderPath = self.indexJSiOSPath else {
            return
        }
        
        NSWorkspace.shared.selectFile(folderPath, inFileViewerRootedAtPath: "")
    }
    
    @IBAction func runiOSClicked(_ sender: Any) {
        
        guard let folderPath = self.folderPath else {
            return
        }
        
        let aplsc = NSAppleScript.init(source: "tell application \"Terminal\" to do script \"cd \(folderPath)\nreact-native run-ios\"")
        
        aplsc?.executeAndReturnError(nil)
    }
    
    @IBAction func runAndroidClicked(_ sender: Any) {
        
        guard let folderPath = self.folderPath else {
            return
        }
        
        let aplsc = NSAppleScript.init(source: "tell application \"Terminal\" to do script \"cd \(folderPath)\nreact-native run-android\"")
        
        aplsc?.executeAndReturnError(nil)
    }
    
    
    func validateIndexJSFile() {
        
        var isDir = ObjCBool(false)
        
        let exceptedIndexJSPath = folderPath! + "/" + "index.js"
        
        if FileManager.default.fileExists(atPath: exceptedIndexJSPath, isDirectory: &isDir) {
            
            self.indexJSAndroidPath = exceptedIndexJSPath
            self.indexJSiOSPath = exceptedIndexJSPath
            
            self.rnIndexJSAndroidPath.stringValue = exceptedIndexJSPath
            self.rnIndexJSiOSPath.stringValue = exceptedIndexJSPath
            
        } else {
            
            
            //This is seperate file located in project root folder
            
            //Check android path
            let exceptedIndexJSAndroidPath = folderPath! + "/" + "index.android.js"
            
            if FileManager.default.fileExists(atPath: exceptedIndexJSAndroidPath, isDirectory: &isDir) {
                
                self.indexJSAndroidPath = exceptedIndexJSAndroidPath
                self.rnIndexJSAndroidPath.stringValue = exceptedIndexJSAndroidPath
                
            } else {
                
                self.rnIndexJSAndroidPath.stringValue = "Not found"
                
            }
            
            
            //Check ios path
            let exceptedIndexJSiOSPath = folderPath! + "/" + "index.ios.js"
            
            if FileManager.default.fileExists(atPath: exceptedIndexJSiOSPath, isDirectory: &isDir) {
                
                self.indexJSiOSPath = exceptedIndexJSiOSPath
                self.rnIndexJSiOSPath.stringValue = exceptedIndexJSiOSPath
                
            } else {
                
                self.rnIndexJSiOSPath.stringValue = "Not found"
                
            }
            
        }
    }
    
}

