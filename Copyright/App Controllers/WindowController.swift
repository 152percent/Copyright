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
import CopyLib

final class WindowController: NSWindowController, NSWindowDelegate {

    @objc dynamic public let licenseManager = LicenseManager.shared

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return UndoManager()
    }

    public func window(_ window: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplication.PresentationOptions = []) -> NSApplication.PresentationOptions {
        return [proposedOptions] //, .autoHideToolbar]
    }

}
