//
//  SplitViewController+FontSizing.swift
//  Copyright
//
//  Created by Shaps Benkau on 28/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

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
