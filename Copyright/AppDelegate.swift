//
//  AppDelegate.swift
//  Copyright
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Cocoa
import CopyLib

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaultSize: CGFloat = 11
        let defaultFont: NSFont = NSFont.userFixedPitchFont(ofSize: defaultSize)
            ?? .systemFont(ofSize: defaultSize)

        UserDefaults.standard.register(defaults: [
            .showLineNumbers: true,
            .fontFamily: defaultFont.familyName!,
            .fontSize: defaultSize,
            .defaultFontSize: defaultSize,
            .whiteListExtensions: ["h", "m", "swift", "js"],
            .blackListPaths: ["Human", "Machine", "Pods", "Carthage", "Build", "fastlane", "Docs"]
        ])

        seedLicensesIfRequired()
    }
    
}

// License Manager – Seeding
extension AppDelegate {

    @IBAction private func seedLicenses(_ sender: Any?) {
        let defaults = UserDefaults.standard
        defaults[.seedLicenses] = true
        seedLicensesIfRequired()
    }

    private func seedLicensesIfRequired() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [.seedLicenses: true])

        guard defaults[.seedLicenses] else { return }
        LicenseManager.shared.seedLicenses()
        UserDefaults.standard[.seedLicenses] = false
    }

}
