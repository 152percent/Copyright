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

    @IBInspectable
    public var tintColor: NSColor? {
        didSet { buttonCell.tintColor = tintColor }
    }

    @IBInspectable
    public var highlightColor: NSColor? {
        didSet { buttonCell.highlightColor = highlightColor }
    }

    open override class var cellClass: Swift.AnyClass? {
        get { return ButtonCell.self }
        set { /* do nothing */ }
    }

    private var buttonCell: ButtonCell {
        return cell as! ButtonCell
    }
    
}

public final class ButtonCell: NSButtonCell {

    fileprivate var tintColor: NSColor?
    fileprivate var highlightColor: NSColor?

    public override func highlightColor(withFrame cellFrame: NSRect, in controlView: NSView) -> NSColor? {
        return highlightColor
    }

    public override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let frame = frame.insetBy(dx: 1, dy: 1)
        let path = NSBezierPath(roundedRect: frame, xRadius: frame.height / 2, yRadius: frame.height / 2)

        if isHighlighted {
            highlightColor?.setStroke()
        } else {
            tintColor?.setStroke()
        }
        
        path.stroke()
    }

    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let bounds = cellFrame.insetBy(dx: 1, dy: 1)
        let radius = bounds.height / 2
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        let imageRect = self.imageRect(forBounds: bounds.offsetBy(dx: 0, dy: 1))

        if isHighlighted {
            highlightColor?.withAlphaComponent(0.3).setFill()
            image?.with(tintColor: .keyboardFocusIndicatorColor).draw(in: imageRect)
        } else {
            tintColor?.withAlphaComponent(0.3).setFill()
            image?.draw(in: imageRect)
        }

        path.fill()

        let titleRect = self.titleRect(forBounds: cellFrame)
        let title = attributedTitle.mutableCopy() as! NSMutableAttributedString
        let range = NSRange(location: 0, length: title.length)

        title.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
        title.draw(in: titleRect.offsetBy(dx: 0, dy: 1))
    }

}
