//
//  LicensesViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

final class LicensesViewController: PreferencesViewController {

    @IBOutlet private weak var textView: SourceEditorView!
    @objc dynamic public let licenseManager = LicenseManager.shared

}
