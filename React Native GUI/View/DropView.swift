//
//  DragView.swift
//  Generate Bundle - React native
//
//  Created by Tejas on 31/03/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Cocoa

class DropView: NSView {
    
    var filePath: String?
    var draggingHandler: ((String)->Void)?
    var clickingHandler: (()->Void)?
    
    func dragging(ended: ((String)->Void)?) {
        draggingHandler = ended
    }
    
    func leftClick(ended: (()->Void)?) {
        clickingHandler = ended
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
        } else {
            // Fallback on earlier versions
            registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String)])
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.lightGray.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        clickingHandler!()
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        
        if directoryExistsAtPath(path) {
            return true
        }
        return false
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        self.filePath = path
        
        draggingHandler!(path)
        
        return true
    }
}
