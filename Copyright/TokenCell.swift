//
//  TokenCell.swift
//  Copyright
//
//  Created by Shaps Benkau on 27/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

public final class TokenCell: NSTextAttachmentCell {

    private var attributedTitle: NSAttributedString {
        let size: CGFloat = UserDefaults.standard[.fontSize]
        let font = NSFont.userFixedPitchFont(ofSize: size)
            ?? NSFont.systemFont(ofSize: size)
        
        return NSAttributedString(string: title, attributes: [
            .foregroundColor: NSColor.white,
            .font: font
        ])
    }

    public override func cellSize() -> NSSize {
        let size = attributedTitle.size()
        return CGSize(width: size.width + 4, height: size.height)
    }

    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        let radius: CGFloat = 4
        let rect = cellFrame.insetBy(dx: 1, dy: 1)
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

        NSColor.keyboardFocusIndicatorColor.setFill()
        path.fill()

        attributedTitle.draw(in: cellFrame)
    }

}
