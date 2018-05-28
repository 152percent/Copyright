//
//  URL+SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 28/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

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
