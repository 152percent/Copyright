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

@IBDesignable
public final class Button: NSButton {

    public override class var cellClass: Swift.AnyClass? {
        get { return ButtonCell.self }
        set { /* do nothing */ }
    }

    private var buttonCell: ButtonCell {
        return cell as! ButtonCell
    }
    
}

public final class ButtonCell: NSButtonCell {

    public override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let frame = frame.insetBy(dx: 1, dy: 1)
        let path = NSBezierPath(roundedRect: frame, xRadius: frame.height / 2, yRadius: frame.height / 2)

        if isHighlighted {
            NSColor.keyboardFocusIndicatorColor.set()
        } else {
            NSColor.clear.setFill()
            NSColor.windowFrameColor.setStroke()
        }

        path.fill()
        path.stroke()
    }

    public override func imageRect(forBounds rect: NSRect) -> NSRect {
        return super.imageRect(forBounds: rect).offsetBy(dx: 0, dy: 1)
    }

}
