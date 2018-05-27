//
//  NSImage+Drawing.swift
//  Copyright
//
//  Created by Shaps Benkau on 28/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

extension NSImage {

    public static func draw(attributedString: NSAttributedString, in rect: CGRect) -> NSImage {
        var rect = rect
        rect.size.height -= 5

        return NSImage(size: rect.size, flipped: false) { rect in
            let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
            NSColor.keyboardFocusIndicatorColor.setFill()
            path.fill()
            attributedString.draw(at: CGPoint(x: 0, y: rect.minY))
            return true
        }
    }

}
