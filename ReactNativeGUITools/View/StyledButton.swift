//
//  StyledButton.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 23/04/24.
//

import Cocoa

class StyledButton: NSView {
    let roundLayer: CALayer = CALayer()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        wantsLayer = true
        layer?.addSublayer(roundLayer)
        roundLayer.frame = bounds
        roundLayer.cornerRadius = 3
        roundLayer.backgroundColor = NSColor.red.cgColor
    }
}
