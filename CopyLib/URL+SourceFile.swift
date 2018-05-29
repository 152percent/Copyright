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

extension URL {

    private var blacklistPaths: [String] {
        let blacklist: [String] = UserDefaults.standard[.blackListPaths] ?? []
        return blacklist.map { $0.lowercased() }
    }

    private var whitelistExtensions: [String] {
        let whitelist: [String] = UserDefaults.standard[.whiteListExtensions] ?? []
        return whitelist.map { $0.lowercased() }
    }

    internal var isDirectory: Bool {
        do {
            return try resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
        } catch { return false }
    }

    // todo: move this to a preference with sensible defaults
    internal var isBlacklisted: Bool {
        for path in blacklistPaths {
            let components = pathComponents.map { $0.lowercased() }

            if components.contains(path) {
                return true
            }
        }

        if isDirectory && pathExtension.isEmpty {
            return false
        }

        return !whitelistExtensions.contains(pathExtension)
    }

}
