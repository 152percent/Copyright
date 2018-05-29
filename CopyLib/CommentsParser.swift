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

private let whitespaceRegex: NSRegularExpression = {
    return regex(for: "whitespace")
}()

/// Returns the range for a series of inline comments, terminated by an empty whitespace line
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func inlineComment(from original: String) -> Range<String.Index>? {
    guard !original.isEmpty else { return nil }

    let originalRange = NSRange(location: 0, length: original.count)
    let range = whitespaceRegex.rangeOfFirstMatch(in: original, options: [], range: originalRange)
    let source = original.trimmingCharacters(in: .whitespacesAndNewlines)

    var commentRange = NSRange(location: NSNotFound, length: 0)
    var offset = 0

    source.enumerateLines { line, stop in
        guard line.hasPrefix("//") else {
            stop = true
            return
        }

        offset += line.count + 1
    }

    guard offset > 0 else { return nil }

    commentRange.location = 0
    commentRange.length = offset

    let originalCommentRange = NSRange(location: commentRange.location + range.length, length: commentRange.length)

    return Range(originalCommentRange, in: source)
}

/// Returns the range for the first block comment found
///
/// - Parameter source: The source to search
/// - Returns: The range of the comment, or NSNotFound if no match was found
internal func blockComment(from original: String) -> Range<String.Index>? {
    guard !original.isEmpty else { return nil }

    let originalRange = NSRange(location: 0, length: original.count)
    let range = whitespaceRegex.rangeOfFirstMatch(in: original, options: [], range: originalRange)

    let source = original.trimmingCharacters(in: .whitespacesAndNewlines)
    let sourceRange = NSRange(location: 0, length: source.count)
    let commentRange = blockCommentRegex.rangeOfFirstMatch(in: source, options: .anchored, range: sourceRange)

    guard commentRange.location != NSNotFound else { return nil }
    let originalCommentRange = NSRange(location: commentRange.location + range.length, length: commentRange.length)

    return Range(originalCommentRange, in: source)
}
