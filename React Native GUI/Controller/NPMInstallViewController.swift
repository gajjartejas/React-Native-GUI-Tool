//
//  NPMViewController.swift
//  React Native GUI
//
//  Created by Tejas on 15/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

class NPMInstallViewController: NSViewController {
    
    @IBOutlet weak var packageNameTextField: NSTextField!
    
    @IBOutlet weak var packageVersionTextField: NSTextField!
    
    @IBOutlet weak var updatePackageCheckBox: NSButton!
    
    @IBOutlet weak var installPackageGloballyCheckBox: NSButton!
    
    @IBOutlet weak var installFromGithubCheckBox: NSButton!
    
    @IBOutlet weak var restorePackageCheckBox: NSButton!
    
    @IBOutlet weak var installPackageButton: NSButton!
    
    var versionNo: String {
        get {
            return packageVersionTextField.stringValue.count > 0 ? "@­\(packageVersionTextField.stringValue)" : ""
        }
    }
    
    var isValidProjectFolder: Bool {
        get {
            guard Project.shared.projectDir != nil else {
                NSAlert.showAlert(title: "Please select react native folder.", message: nil, style: .warning)
                return false
            }
            
            return true
        }
    }
    
    var isValidPackageName: Bool {
        get {
            guard packageNameTextField.stringValue.count > 0 else {
                NSAlert.showAlert(title: "Please add package name.", message: nil, style: .warning)
                return false
            }
            
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchUpdatePackageJsonePackage()
    }
    
    
    @IBAction func updatePackageCheckBoxTapped(_ sender: NSButton) {
        
        if updatePackageCheckBox.state == .on {
            switchUpdatePackageJsonePackage()
        } else {
            switchDoNotUpdatePackageJsonePackage()
        }
    }
    
    @IBAction func installPackageGloballyCheckBoxTapped(_ sender: NSButton) {
        
        if installPackageGloballyCheckBox.state == .on {
            switchGloballyPackage()
        } else {
            switchDoNotUpdatePackageJsonePackage()
        }
    }
    
    @IBAction func installFromGithubCheckBoxTapped(_ sender: NSButton) {
        
        if installFromGithubCheckBox.state == .on {
            switchGitHubPackage()
        } else {
            switchDoNotUpdatePackageJsonePackage()
        }
    }
    
    @IBAction func restorePackageCheckBoxTapped(_ sender: NSButton) {
        
        if restorePackageCheckBox.state == .on {
            switchRestorePackage()
        } else {
            switchDoNotUpdatePackageJsonePackage()
        }
    }
    
    @IBAction func installPackageClicked(_ sender: NSButton) {
        
        if updatePackageCheckBox.state == .on {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm install \(packageNameTextField.stringValue)\(versionNo) --save"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
            
        } else if installPackageGloballyCheckBox.state == .on {
            
            let command = "npm install \(packageNameTextField.stringValue) -g"
            
            let source = "tell application \"Terminal\" to do script \"\(command)\""
            
            execute(source: source)
            
        } else if installFromGithubCheckBox.state == .on {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm install \(packageNameTextField.stringValue)"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
            
        } else if restorePackageCheckBox.state == .on {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm install"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
            
        } else {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm install \(packageNameTextField.stringValue)\(versionNo)"
            
             let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
        }
    }
    
    func switchUpdatePackageJsonePackage() {
        
        packageNameTextField.placeholderString = "Package Name"
        packageVersionTextField.placeholderString = "Package Version (Optional)"
        
        packageNameTextField.isEnabled = true
        packageVersionTextField.isEnabled = true
        
        installPackageGloballyCheckBox.state = .off
        installFromGithubCheckBox.state = .off
        restorePackageCheckBox.state = .off
        
        installPackageButton.title = "Install Package"
    }
    
    func switchDoNotUpdatePackageJsonePackage() {
        
        packageNameTextField.placeholderString = "Package Name"
        packageVersionTextField.placeholderString = "Package Version (Optional)"
        
        packageNameTextField.isEnabled = true
        packageVersionTextField.isEnabled = true
        
        updatePackageCheckBox.state = .off
        installPackageGloballyCheckBox.state = .off
        installFromGithubCheckBox.state = .off
        restorePackageCheckBox.state = .off
        
        installPackageButton.title = "Install Package"
    }
    
    func switchGloballyPackage() {
        
        packageNameTextField.placeholderString = "Package Name"
        packageVersionTextField.placeholderString = "Package Version (Optional)"
        
        packageNameTextField.isEnabled = true
        packageVersionTextField.isEnabled = true
        
        updatePackageCheckBox.state = .off
        installFromGithubCheckBox.state = .off
        restorePackageCheckBox.state = .off
        
        installPackageButton.title = "Install Package"
    }
    
    func switchGitHubPackage() {
        
        packageNameTextField.placeholderString = "Gi­tHu­b-U­RL"
        packageVersionTextField.placeholderString = "Package Version (Optional)"
        
        packageNameTextField.isEnabled = true
        packageVersionTextField.isEnabled = false
        
        updatePackageCheckBox.state = .off
        installPackageGloballyCheckBox.state = .off
        restorePackageCheckBox.state = .off
        
        installPackageButton.title = "Install Package"
    }
    
    func switchRestorePackage() {
        
        packageNameTextField.placeholderString = "Package Name"
        packageVersionTextField.placeholderString = "Package Version (Optional)"
        
        packageNameTextField.isEnabled = false
        packageVersionTextField.isEnabled = false
        
        updatePackageCheckBox.state = .off
        installPackageGloballyCheckBox.state = .off
        installFromGithubCheckBox.state = .off
        
        installPackageButton.title = "Restore Packages"
    }
    
    func execute(source: String)  {
        
        let aplsc = NSAppleScript.init(source: source)
        
        aplsc?.executeAndReturnError(nil)
    }
    
}
