//
//  NSView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 27/04/24.
//

import Cocoa

extension NSView {
    func addDashedBorder() {
        let color = NSColor.red.cgColor

        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = NSColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6, 3]
        shapeLayer.path = NSBezierPath(roundedRect: shapeRect, xRadius: 10.0, yRadius: 10.0).cgPath

        layer?.addSublayer(shapeLayer)
    }
}

extension NSView {
    var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension NSView {
    var cornerRadius: CGFloat? {
        get {
            return layer?.cornerRadius
        }
        set {
            wantsLayer = true
            canDrawSubviewsIntoLayer = true
            layer?.cornerRadius = 4.0
            layer?.masksToBounds = true
        }
    }
}
