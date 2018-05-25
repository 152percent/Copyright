//
//  SeparatorView.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

@IBDesignable
public final class SeparatorView: NSView {

    @IBOutlet private weak var scrollView: SynchronizedScrollView!

    @IBInspectable
    public var fillColor: NSColor? {
        didSet { setNeedsDisplay(bounds) }
    }

    @IBInspectable
    public var strokeColor: NSColor? {
        didSet { setNeedsDisplay(bounds) }
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        strokeColor?.setStroke()
        fillColor?.setFill()

        let path = NSBezierPath(rect: dirtyRect)
        path.fill()
        path.stroke()
    }

    public override func scrollWheel(with event: NSEvent) {
        scrollView.scrollWheel(with: event)
    }

}
