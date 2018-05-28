//
//  NSImage+Drawing.swift <#comapny#>
//  Copyright
//
//  Created by Shaps Benkau on 28/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

extension NSImage {

    public static func draw(attributedString: NSAttributedString, in rect: CGRect) -> NSImage {
        var rect = rect
        rect.size.height -= 2
        rect.size.width += 6

        return NSImage(size: rect.size, flipped: false) { rect in
            let context = NSGraphicsContext.current!.cgContext
            context.translateBy(x: 0, y: rect.height)
            context.scaleBy(x: 1.0, y: -1.0)

            let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
            NSColor.keyboardFocusIndicatorColor.setFill()
            path.fill()
            attributedString.draw(at: CGPoint(x: 3, y: rect.minY))

            return true
        }
    }

}
