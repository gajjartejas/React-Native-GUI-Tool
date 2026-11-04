//
//  AddCustomActionVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 22/09/24.
//

import Cocoa

class AddCustomActionVC: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func onPressCancel(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    @IBAction func onPressOkay(_ sender: NSButton) {
        self.dismiss(self)
    }
}
