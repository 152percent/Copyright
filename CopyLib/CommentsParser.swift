//
//  CommentsParser.swift
//  CopyLib
//
//  Created by Shaps Benkau on 26/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

// swiftlint:disable force_try

import Foundation

public func regex(for resource: String) -> NSRegularExpression {
    let url = Bundle(for: SourceFile.self).url(forResource: resource, withExtension: "regex")!
    let pattern = try! String(contentsOf: url)
    return try! NSRegularExpression(pattern: pattern, options: [])
}

private let blockCommentRegex: NSRegularExpression = {
    return regex(for: "block")
}()

private let inlineCommentRegex: NSRegularExpression = {
    return regex(for: "inline")
}()

/// Returns the range for the first block comment found
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func blockComment(from original: String) -> Range<String.Index>? {
    let source = original.trimmingCharacters(in: .whitespacesAndNewlines)
    let sourceRange = NSRange(location: 0, length: source.count)
    let commentRange = blockCommentRegex.rangeOfFirstMatch(in: source, options: .anchored, range: sourceRange)

    guard commentRange.location != NSNotFound else { return Range(NSRange(location: 0, length: 0), in: source) }
    return Range(commentRange, in: source)
}

/// Returns the range for a series of inline comments, terminated by an empty whitespace line
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func inlineComment(from source: String) -> Range<String.Index>? {
    let sourceRange = NSRange(location: 0, length: source.count)
    let commentRange = inlineCommentRegex.rangeOfFirstMatch(in: source, options: [], range: sourceRange)
    return Range(commentRange, in: source)
}
