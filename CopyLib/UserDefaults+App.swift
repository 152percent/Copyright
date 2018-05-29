//
//  UserDefaults+Keys.swift
//  CopyLib
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension UserDefaults.Key {
    public static let seedLicenses: UserDefaults.Key = "SeedLicenses"
    public static let currentLicense: UserDefaults.Key = "CurrentLicense"
    public static let showLineNumbers: UserDefaults.Key = "ShowLineNumbers"

    public static let fontFamily: UserDefaults.Key = "SourceFontFamily"
    public static let fontSize: UserDefaults.Key = "SourceFontSize"
    public static let defaultFontSize: UserDefaults.Key = "DefaultSourceFontSize"

    public static let sourceTextColor: UserDefaults.Key = "SourceTextColor"
    public static let commentTextColor: UserDefaults.Key = "CommentTextColor"

    public static let whiteListExtensions: UserDefaults.Key = "WhitelistExtensions"
    public static let blackListPaths: UserDefaults.Key = "BlacklistPaths"
}
