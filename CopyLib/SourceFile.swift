//
//  SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

@objc public final class SourceFile: NSObject {

    @objc dynamic public let url: NSURL
    @objc dynamic public fileprivate(set) var parent: SourceFile?
    @objc dynamic public fileprivate(set) var children: [SourceFile] = []

    @objc public init(url: NSURL) {
        self.url = url
    }

}

extension Array where Element == SourceFile {

    public var cleaned: ([SourceFile], Int) {
        var fileCount: Int = 0
        var files: [SourceFile] = []

        for file in self {
            if file.isDirectory && file.children.cleaned.0.isEmpty { continue }

            let newFile = SourceFile(url: file.url)
            newFile.parent = file.parent
            newFile.children = file.children.cleaned.0

            if newFile.isDirectory {
                fileCount += newFile.children.count
            } else {
                fileCount += 1
            }

            files.append(newFile)
        }

        return (files, fileCount)
    }

}

extension SourceFile {

    @objc dynamic var isDirectory: Bool {
        var isDirectory: AnyObject?
        try? url.getResourceValue(&isDirectory, forKey: .isDirectoryKey)
        return isDirectory as? Bool ?? false
    }

    @objc dynamic var icon: NSImage {
        if isDirectory {
            return NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
        }

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

extension SourceFile {

    internal func add(_ file: SourceFile) {
        file.parent = self
        children.append(file)
    }

    @objc dynamic var isLeaf: Bool {
        return children.isEmpty
    }

    @objc dynamic var count: Int {
        return children.count
    }

}

extension SourceFile: NSCopying {

    @objc dynamic public func copy(with zone: NSZone? = nil) -> Any {
        let copy = SourceFile(url: self.url)
        copy.parent = parent
        copy.children = children
        return copy
    }

}
