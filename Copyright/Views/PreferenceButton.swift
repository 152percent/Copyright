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

//@IBDesignable
//public final class PreferenceButton: NSButton {
//
//    @IBInspectable
//    public var tintColor: NSColor? {
//        didSet { buttonCell.tintColor = tintColor }
//    }
//
//    @IBInspectable
//    public var highlightColor: NSColor? {
//        didSet { buttonCell.highlightColor = highlightColor }
//    }
//
//    public override class var cellClass: Swift.AnyClass? {
//        get { return PreferenceButtonCell.self }
//        set { /* do nothing */ }
//    }
//
//    private var buttonCell: PreferenceButtonCell {
//        return cell as! PreferenceButtonCell
//    }
//
//}
//
//public final class PreferenceButtonCell: NSButtonCell {
//
//    fileprivate var tintColor: NSColor?
//    fileprivate var highlightColor: NSColor?
//
//    public override func highlightColor(withFrame cellFrame: NSRect, in controlView: NSView) -> NSColor? {
//        return NSColor.highlightColor
//    }
//
//    public override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
//        let frame = frame
//        let path = NSBezierPath(rect: frame)
//
//        NSColor.windowFrameColor.setStroke()
//        path.stroke()
//    }
//
//    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
//        let bounds = cellFrame
//        let imageRect = self.imageRect(forBounds: bounds)
//
//        if isHighlighted {
//            NSColor.selectedControlColor.setFill()
//            image?.with(tintColor: .white).draw(in: imageRect)
//        } else {
//            NSColor.controlBackgroundColor.setFill()
//            image?.draw(in: imageRect)
//        }
//
//        cellFrame.fill()
//
//        let titleRect = self.titleRect(forBounds: cellFrame)
//        let title = attributedTitle.mutableCopy() as! NSMutableAttributedString
//        let range = NSRange(location: 0, length: title.length)
//
//        title.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
//        title.draw(in: titleRect.offsetBy(dx: -1, dy: -1))
//    }
//
//}
