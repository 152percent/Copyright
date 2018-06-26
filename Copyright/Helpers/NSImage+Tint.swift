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

    public func with(tintColor: NSColor? = NSColor.selectedControlTextColor) -> NSImage {
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
