//
//  SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

@objc public final class SourceFile: NSObject {

    @objc public let url: NSURL

    @objc public init(url: NSURL) {
        self.url = url
    }

}

extension SourceFile {

    @objc var isDirectory: Bool {
        var isDirectory: AnyObject?
        try? url.getResourceValue(&isDirectory, forKey: .isDirectoryKey)
        return isDirectory as? Bool ?? false
    }

    @objc var icon: NSImage {
        switch url.pathExtension {
        case nil:
            return NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
        case "h":
            return NSImage(named: NSImage.Name(rawValue: "header"))!
        case "m":
            return NSImage(named: NSImage.Name(rawValue: "implementation"))!
        default:
            return NSImage(named: NSImage.Name(rawValue: "swift"))!
        }
    }

}
