/*
    2016-2018 152 Percent Ltd
    All Rights Reserved.

    NOTICE: All information contained herein is, and remains
    the property of 152 Percent Ltd and its suppliers,
    if any. The intellectual and technical concepts contained
    herein are proprietary to 152 Percent Ltd and its suppliers,
    and are protected by trade secret or copyright law.
    Dissemination of this information or reproduction of this material
    is strictly forbidden unless prior written permission is obtained
    from 152 Percent Ltd.
 */
   
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
