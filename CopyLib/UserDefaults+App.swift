//
//  UserDefaults+Keys.swift
//  CopyLib
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {
    public static let app = UserDefaults(suiteName: "com.152percent.copyright.preferences")!
}

extension UserDefaults.Key {
    public static let seedLicenses: UserDefaults.Key = "SeedLicenses"
    public static let fontSize: UserDefaults.Key = "SourceFontSize"
}
