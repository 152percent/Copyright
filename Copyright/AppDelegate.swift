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
        seedLicensesIfRequired()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}

// License Manager – Seeding
extension AppDelegate {

    @IBAction private func seedLicenses(_ sender: Any?) {
        let defaults = UserDefaults.app
        defaults[.seedLicenses] = true
        seedLicensesIfRequired()
    }

    private func seedLicensesIfRequired() {
        let defaults = UserDefaults.app
        defaults.register(defaults: [.seedLicenses: true])

        guard defaults[.seedLicenses] else { return }
        LicenseManager.shared.seedLicenses()
        UserDefaults.app[.seedLicenses] = false
    }

}
