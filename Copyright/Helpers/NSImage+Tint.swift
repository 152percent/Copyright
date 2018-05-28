//
//  NSImage+Tint.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

extension NSImage {

    public func with(tintColor: NSColor? = NSColor.selectedControlTextColor) -> NSImage {
        guard self.isTemplate else { return self }

        let image = self.copy() as! NSImage
        image.lockFocus()

        tintColor?.set()
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        rect.fill(using: .sourceAtop)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }

}
