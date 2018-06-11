//
//  String+LineCount.swift
//  Copyright
//
//  Created by Shaps Benkau on 11/06/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

public extension String {

    /// Highly efficient approach to finding the number of lines in a string
    ///
    /// - Parameter string: The source string
    /// - Returns: The number of lines in the string
    var lineCount: Int {
        return lineCount(in: startIndex..<endIndex)
    }

    func lineCount(in range: Range<String.Index>) -> Int {
        let range = NSRange(range, in: self)
        return lineCount(in: range)
    }

    func lineCount(in range: NSRange) -> Int {
        var lineCount = 0
        var buffer = CFStringInlineBuffer()
        CFStringInitInlineBuffer(self as CFString, &buffer, CFRangeMake(range.location, range.length))

        for index in 0..<count {
            let c = CFStringGetCharacterFromInlineBuffer(&buffer, index)

            // check for '\n' newline character
            if c == 0x000A {
                lineCount += 1
            }
        }

        return lineCount
    }

}
