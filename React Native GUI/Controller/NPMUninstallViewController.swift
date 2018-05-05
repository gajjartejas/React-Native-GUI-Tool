//
//  NPMUninstallViewController.swift
//  React Native GUI
//
//  Created by Tejas on 15/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

class NPMUninstallViewController: NSViewController {
    
    @IBOutlet weak var packageNameTextField: NSTextField!
    
    @IBOutlet weak var removePackageCheckBox: NSButton!
    
    @IBOutlet weak var removePackageGloballyCheckBox: NSButton!
    
    @IBOutlet weak var removeExtraneousPackagesCheckBox: NSButton!
    
    @IBOutlet weak var clearNPMCacheCheckBox: NSButton!
    
    @IBOutlet weak var uninstallPackageButton: NSButton!
    
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
    }
    
    @IBAction func removePackageCheckBoxTapped(_ sender: NSButton) {
        if removePackageCheckBox.state == .on {
            switchRemovePackagePackage()
        } else {
            switchDoNotRemovePackage()
        }
    }
    
    @IBAction func removePackageGloballyCheckBoxTapped(_ sender: NSButton) {
        if removePackageGloballyCheckBox.state == .on {
            switchRemovePackageGlobally()
        } else {
            switchDoNotRemovePackage()
        }
    }
    
    @IBAction func removeExtraneousPackagesCheckBoxTapped(_ sender: NSButton) {
        if removeExtraneousPackagesCheckBox.state == .on {
            switcRemoveExtraneousPackages()
        } else {
            switchDoNotRemovePackage()
        }
    }
    
    @IBAction func clearNPMCacheCheckBoxTapped(_ sender: NSButton) {
        if clearNPMCacheCheckBox.state == .on {
            switchclearNPMCache()
        } else {
            switchDoNotRemovePackage()
        }
        
    }
    
    @IBAction func uninstallPackageTapped(_ sender: NSButton) {
        
        if removePackageCheckBox.state == .on {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm uninstall \(packageNameTextField.stringValue) --save"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
            
            
        } else if removePackageGloballyCheckBox.state == .on {
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm uninstall \(packageNameTextField.stringValue) -g"
            
            let source = "tell application \"Terminal\" to do script \"\(command)\""
            
            execute(source: source)
            
        } else if removeExtraneousPackagesCheckBox.state == .on {
            
            if !isValidProjectFolder {
                return
            }
            
            let command = "npm prune"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            
            execute(source: source)
            
        } else if clearNPMCacheCheckBox.state == .on {
            
            let command = "npm cache clean --force"
            
            let source = "tell application \"Terminal\" to do script \"\(command)\""
            
            execute(source: source)
            
        } else {
            
            if !isValidProjectFolder {
                return
            }
            
            if !isValidPackageName {
                return
            }
            
            let command = "npm uninstall \(packageNameTextField.stringValue)"
            
            let source = "tell application \"Terminal\" to do script \"cd \'\(Project.shared.projectDir!)\'\n\(command)\""
            
            execute(source: source)
            
        }
    }
    
    func switchDoNotRemovePackage() {
        
        packageNameTextField.isEnabled = true
        
        removePackageCheckBox.state = .off
        removePackageGloballyCheckBox.state = .off
        removeExtraneousPackagesCheckBox.state = .off
        clearNPMCacheCheckBox.state = .off
        
        uninstallPackageButton.title = "Uninstall Package"
    }
    
    func switchRemovePackagePackage() {
        
        packageNameTextField.isEnabled = true
        
        removePackageGloballyCheckBox.state = .off
        removeExtraneousPackagesCheckBox.state = .off
        clearNPMCacheCheckBox.state = .off
        
        uninstallPackageButton.title = "Uninstall Package"
    }
    
    func switchRemovePackageGlobally() {
        
        packageNameTextField.isEnabled = true
        
        removePackageCheckBox.state = .off
        removeExtraneousPackagesCheckBox.state = .off
        clearNPMCacheCheckBox.state = .off
        
        uninstallPackageButton.title = "Uninstall Package"
    }
    
    func switcRemoveExtraneousPackages() {
        
        packageNameTextField.isEnabled = false
        
        removePackageCheckBox.state = .off
        removePackageGloballyCheckBox.state = .off
        clearNPMCacheCheckBox.state = .off
        
        uninstallPackageButton.title = "Remove Unused Packages"
    }
    
    func switchclearNPMCache() {
        
        packageNameTextField.isEnabled = false
        
        removePackageCheckBox.state = .off
        removePackageGloballyCheckBox.state = .off
        removeExtraneousPackagesCheckBox.state = .off
        
        uninstallPackageButton.title = "Clear NPM Cache"
    }
    
    func execute(source: String)  {
        
        let aplsc = NSAppleScript.init(source: source)
        
        aplsc?.executeAndReturnError(nil)
    }
}
