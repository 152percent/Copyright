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
public final class PreferenceButton: NSButton {

    public override class var cellClass: Swift.AnyClass? {
        get { return PreferenceButtonCell.self }
        //swiftlint:disable unused_setter_value
        set { /* do nothing */ }
    }

    private var buttonCell: PreferenceButtonCell {
        return cell as! PreferenceButtonCell
    }

}

public final class PreferenceButtonCell: NSButtonCell {

    public override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if isHighlighted {
            NSColor.highlightColor.setFill()
        } else {
            NSColor.clear.setFill()
        }

        frame.fill()
        NSColor.gridColor.set()
        frame.insetBy(dx: 0, dy: 1).frame()
    }

}
