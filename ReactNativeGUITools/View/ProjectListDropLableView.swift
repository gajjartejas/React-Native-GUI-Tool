//
//  ProjectListDropLableView.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 27/04/24.
//

import Cocoa

class ProjectListDropLableView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Dash customization parameters
        let borderRadious: CGFloat = 8
        let dashHeight: CGFloat = 2.5
        let dashLength: CGFloat = 5
        let dashColor: NSColor = .systemGray

        // Setup the context
        guard let currentContext = NSGraphicsContext.current?.cgContext else { return }
        currentContext.setLineWidth(dashHeight)
        currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)

        // Draw the dashed path with rounded corners
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: dashHeight / 2, dy: dashHeight / 2), xRadius: borderRadious, yRadius: borderRadious)
        currentContext.addPath(path.cgPath)
        currentContext.strokePath()
    }
}
