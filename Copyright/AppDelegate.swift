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
   
import Cocoa
import CopyLib
import os

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaultSize: CGFloat = 11
        let defaultFont = NSFont
            .userFixedPitchFont(ofSize: defaultSize)
            ?? .systemFont(ofSize: defaultSize)

        UserDefaults.standard.register(defaults: [
            .showLineNumbers: false,
            .fontFamily: defaultFont.familyName!,
            .fontSize: defaultSize,
            .defaultFontSize: defaultSize,
            .whiteListExtensions: ["h", "m", "swift", "js"],
            .blackListPaths: ["Human", "Machine", "Pods", "Carthage", "Build", "fastlane", "Docs"]
        ])

        seedLicensesIfRequired()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
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
