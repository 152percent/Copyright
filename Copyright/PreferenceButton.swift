//
//  PreferenceButton.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

@IBDesignable
public final class PreferenceButton: NSButton {

    @IBInspectable
    public var tintColor: NSColor? {
        didSet { buttonCell.tintColor = tintColor }
    }

    @IBInspectable
    public var highlightColor: NSColor? {
        didSet { buttonCell.highlightColor = highlightColor }
    }

    open override class var cellClass: Swift.AnyClass? {
        get { return PreferenceButtonCell.self }
        set { /* do nothing */ }
    }

    private var buttonCell: PreferenceButtonCell {
        return cell as! PreferenceButtonCell
    }

}

public final class PreferenceButtonCell: NSButtonCell {

    fileprivate var tintColor: NSColor?
    fileprivate var highlightColor: NSColor?

    public override func highlightColor(withFrame cellFrame: NSRect, in controlView: NSView) -> NSColor? {
        return highlightColor
    }

    public override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let frame = frame
        let path = NSBezierPath(rect: frame)

        NSColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).setStroke()
        path.stroke()
    }

    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let bounds = cellFrame
        let imageRect = self.imageRect(forBounds: bounds)

        if isHighlighted {
            highlightColor?.withAlphaComponent(0.3).setFill()
            image?.with(tintColor: .keyboardFocusIndicatorColor).draw(in: imageRect)
        } else {
            tintColor?.withAlphaComponent(0.4).setFill()
            image?.draw(in: imageRect)
        }

        cellFrame.fill()

        let titleRect = self.titleRect(forBounds: cellFrame)
        let title = attributedTitle.mutableCopy() as! NSMutableAttributedString
        let range = NSRange(location: 0, length: title.length)

        title.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
        title.draw(in: titleRect.offsetBy(dx: -1, dy: -1))
    }

}
