//
//  SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension NSURL {

    @objc dynamic public var isDirectory: Bool {
        return (self as URL).isDirectory
    }

}

@objc public enum SourceFileResolution: Int {
    case add
    case modify
    case delete
    case ignore
    case resolved
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
            case .resolved: resolutionChar = "✓"
            }

            children.forEach { $0.resolution = resolution }

            // trigger KVO so bindings update
            willChangeValue(for: \.resolvedSource)
            didChangeValue(for: \.resolvedSource)
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

            // trigger KVO so bindings update
            willChangeValue(for: \.resolutionChar)
            _resolutionChar = newValue
            didChangeValue(for: \.resolutionChar)
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

}

extension SourceFile {

    public override var description: String {
        return recursiveDescription(level: 0)
    }

    private func recursiveDescription(level: Int) -> String {
        let indent = Array(repeating: " ", count: 4 * level).joined()

        if url.isDirectory {
            return """
            \(indent)▾ \(url)
            \(children.map { $0.recursiveDescription(level: level + 1) }.joined(separator: "\n"))
            """
        } else {
            return "\(indent)• \(url.path!)"
        }
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

    internal func add(_ files: [SourceFile]) {
        files.forEach { $0.parent = self }
        children.append(contentsOf: files)
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

    private var sourceFont: NSFont {
        let size: CGFloat = UserDefaults.standard[.fontSize]
        return NSFont.userFixedPitchFont(ofSize: size)
            ?? NSFont.systemFont(ofSize: size)
    }

    internal var codeAttributes: [NSAttributedStringKey: Any] {
        return [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: sourceFont
        ]
    }

    internal var commentAttributes: [NSAttributedStringKey: Any] {
        return [
            .foregroundColor: NSColor(red: 29/255, green: 133/255, blue: 25/255, alpha: 1),
            .font: sourceFont
        ]
    }

    @objc dynamic public var source: String {
        guard let source = try? String(contentsOf: url as URL) else { return "" }
        return source
    }

    @objc dynamic public var attributedSource: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: source, attributes: codeAttributes)
        let comment = String(source[commentRange])
        let commentString = NSAttributedString(string: comment, attributes: commentAttributes)

        attributedString.replaceCharacters(in: NSRange(commentRange, in: commentString.string), with: commentString)
        return attributedString
    }

    internal var commentRange: Range<String.Index> {
        let source = self.source
        return blockComment(from: source)
            ?? inlineComment(from: source)
            ?? Range(NSRange(location: 0, length: 0), in: source)!
    }
    
}
