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

private let newlineRegex: NSRegularExpression = {
    return regex(for: "newline")
}()

/// Returns the range for a series of inline comments, terminated by an empty whitespace line
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func inlineComment(from source: String) -> Range<String.Index>? {
    let sourceRange = NSRange(location: 0, length: source.count)
    let commentRange = inlineCommentRegex.rangeOfFirstMatch(in: source, options: [], range: sourceRange)
    return Range(commentRange, in: source)
}

/// Returns the range for the first block comment found
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func blockComment(from original: String) -> Range<String.Index>? {
    guard !original.isEmpty else { return nil }

    let originalRange = NSRange(location: 0, length: original.count)
    let range = newlineRegex.rangeOfFirstMatch(in: original, options: [], range: originalRange)

    let source = original.trimmingCharacters(in: .whitespacesAndNewlines)
    let sourceRange = NSRange(location: 0, length: source.count)
    let commentRange = blockCommentRegex.rangeOfFirstMatch(in: source, options: .anchored, range: sourceRange)

    guard commentRange.location != NSNotFound else { return nil }
    let originalCommentRange = NSRange(location: commentRange.location + range.length, length: commentRange.length)
    return Range(originalCommentRange, in: source)
}
