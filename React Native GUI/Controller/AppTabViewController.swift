//
//  AppTabViewController.swift
//  React Native GUI
//
//  Created by Tejas on 09/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import AppKit

class AppTabViewController: NSTabViewController {
    lazy var originalSizes = [String : NSSize]()
    
    // MARK: - NSTabViewDelegate
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)
        
        _ = tabView.selectedTabViewItem
        let originalSize = self.originalSizes[tabViewItem!.label]
        if (originalSize == nil) {
            self.originalSizes[tabViewItem!.label] = (tabViewItem!.view?.frame.size)!
        }
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        
        let window = self.view.window
        if (window != nil) {
            window?.title = tabViewItem!.label
            let size = (self.originalSizes[tabViewItem!.label])!
            let contentFrame = (window?.frameRect(forContentRect: NSMakeRect(0.0, 0.0, size.width, size.height)))!
            var frame = (window?.frame)!
            frame.origin.y = frame.origin.y + (frame.size.height - contentFrame.size.height)
            frame.size.height = contentFrame.size.height;
            frame.size.width = contentFrame.size.width;
            window?.setFrame(frame, display: false, animate: true)
        }
        
        //        tabViewItem!.view?.hidden = false
    }
}
