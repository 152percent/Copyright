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
