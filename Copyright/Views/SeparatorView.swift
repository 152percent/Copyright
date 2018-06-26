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
public final class SeparatorView: NSView {

    @IBOutlet private weak var scrollView: SynchronizedScrollView?

    @IBInspectable
    public var fillColor: NSColor? {
        didSet { setNeedsDisplay(bounds) }
    }

    @IBInspectable
    public var strokeColor: NSColor? = .clear {
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
        scrollView?.scrollWheel(with: event)
    }

}
