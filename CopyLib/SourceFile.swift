//
//  SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension NSURL {

    // swiftlint:disable force_try
    @objc dynamic public var isDirectory: Bool {
        var isDirectory: AnyObject?
        try! getResourceValue(&isDirectory, forKey: .isDirectoryKey)
        return isDirectory as? Bool ?? false
    }

}

@objc public enum SourceFileResolution: Int {
    case add
    case modify
    case delete
    case ignore
}

@objc public final class SourceFile: NSObject {

    @objc dynamic public let url: NSURL
    @objc dynamic public fileprivate(set) var parent: SourceFile?
    @objc dynamic public fileprivate(set) var children: [SourceFile] = []
    @objc dynamic public var resolution: SourceFileResolution = .ignore {
        didSet {
            switch resolution {
            case .add: resolutionChar = "A"
            case .modify: resolutionChar = "M"
            case .delete: resolutionChar = "D"
            case .ignore: resolutionChar = ""
            }

            children.forEach { $0.resolution = resolution }
        }
    }

    @objc public init(url: NSURL) {
        self.resolution = .ignore
        self.url = url
    }

    private var _resolutionChar: String = ""
    @objc dynamic public var resolutionChar: String {
        get {
            return _resolutionChar
        } set {
            guard !url.isDirectory else { return }

            willChangeValue(forKey: "resolutionChar")
            _resolutionChar = newValue
            didChangeValue(forKey: "resolutionChar")
        }
    }

}

extension Array where Element == SourceFile {

    public var urls: [NSURL] {
        var urls = map { $0.url }

        for file in self where file.url.isDirectory {
            urls.append(contentsOf: file.children.map { $0.url })
        }

        return urls
    }

    /// Removes empty directories from the tree
    public var cleaned: ([SourceFile], Int) {
        var fileCount: Int = 0
        var files: [SourceFile] = []

        for file in self {
            if file.isDirectory && file.children.cleaned.0.isEmpty { continue }

            let newFile = SourceFile(url: file.url)
            newFile.parent = file.parent
            let cleaned = file.children.cleaned

            newFile.children = cleaned.0
            fileCount += cleaned.1

            if !newFile.isDirectory {
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
            return NSImage(named: NSImage.Name(rawValue: "folder"))!
        }

        switch url.pathExtension {
        case nil:
            return NSImage(named: NSImage.Name(rawValue: "header"))!
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
        return type(of: self).init(url: url)
    }

}

extension SourceFile {

    @objc dynamic public var source: String {
        guard let source = try? String(contentsOf: url as URL) else { return "" }
        return source
    }

    @objc dynamic public var attributedSource: NSAttributedString {
        let size: CGFloat = UserDefaults.standard[.fontSize]
        let font = NSFont.userFixedPitchFont(ofSize: size)
            ?? NSFont.systemFont(ofSize: size)

        let attributedString = NSMutableAttributedString(string: source, attributes: [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: font
        ])

        if let commentRange = self.commentRange {
            let commentAttributes: [NSAttributedStringKey: Any] = [
                .foregroundColor: NSColor(red: 29/255, green: 133/255, blue: 25/255, alpha: 1),
                .font: font
            ]

            let comment = String(source[commentRange])
            let commentString = NSAttributedString(string: comment, attributes: commentAttributes)

            attributedString.replaceCharacters(in: NSRange(commentRange, in: commentString.string), with: commentString)
        }

        return attributedString
    }

    private var commentRange: Range<String.Index>? {
        let source = self.source
        return blockComment(from: source)
            ?? inlineComment(from: source)
    }
    
}
