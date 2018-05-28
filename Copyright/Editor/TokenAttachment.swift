//
//  TokenCell.swift
//  Copyright
//
//  Created by Shaps Benkau on 27/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

public final class TokenAttachment: NSTextAttachment {

    public var token: NSAttributedString?
    public var fontDescender: CGFloat = 0

    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: NSRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> NSRect {
        var bounds = super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        bounds.origin.y = fontDescender
        return bounds
    }

}
