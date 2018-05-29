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
   
import Foundation

extension SplitViewController {

    @IBAction private func resetFontSize(_ sender: Any?) {
        updateFontSize(initial: UserDefaults.standard[.defaultFontSize], with: 0)
    }

    @IBAction private func increaseFontSize(_ sender: Any?) {
        let initial: CGFloat = UserDefaults.standard[.fontSize]
        updateFontSize(initial: initial, with: 1)
    }

    @IBAction private func decreaseFontSize(_ sender: Any?) {
        let initial: CGFloat = UserDefaults.standard[.fontSize]
        updateFontSize(initial: initial, with: -1)
    }

    private func updateFontSize(initial size: CGFloat, with delta: CGFloat) {
        let newSize = size + delta
        UserDefaults.standard[.fontSize] = newSize
    }

}
