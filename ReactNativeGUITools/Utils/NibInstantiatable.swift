//
//  NibInstantiatable.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 14/04/24.
//

import Cocoa

protocol NibInstantiatable: AnyObject {
    static var nibName: String { get }
    static func nib(inBundle bundle: Bundle?) -> NSNib
    static func fromNib(inBundle bundle: Bundle?, filesOwner: Any?) -> Self
}

extension NibInstantiatable {
    static var nibName: String {
        return "\(Self.self)"
    }

    static func nib(inBundle bundle: Bundle?) -> NSNib {
        return NSNib(nibNamed: NSNib.Name("\(nibName)"), bundle: bundle)!
    }

    static func fromNib(inBundle bundle: Bundle? = nil, filesOwner: Any? = nil) -> Self {
        var objs: NSArray?
        let nib = self.nib(inBundle: bundle)
        nib.instantiate(withOwner: filesOwner, topLevelObjects: &objs)
        if let objs = objs {
            let objs_ = objs.filter { $0 is Self == true } as NSArray
            return objs_.lastObject as! Self
        }

        assert(false, "nib error")
    }
}
