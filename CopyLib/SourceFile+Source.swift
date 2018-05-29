//
//  SourceFile+License.swift
//  CopyLib
//
//  Created by Shaps Benkau on 29/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension SourceFile {

    private var attributedLicense: NSAttributedString {
        guard let identifier: String = UserDefaults.standard[.currentLicense] else {
            return NSAttributedString(string: "")
        }

        let license = LicenseManager.shared.licenses.first(where: { $0.identifier == identifier })
            ?? License(name: "", content: nil)

        let content = (license.content ?? "")
        return NSAttributedString(string: content, attributes: commentAttributes)
    }

    @objc dynamic public var resolvedSource: NSAttributedString? {
        guard !url.isDirectory else { return nil }
        
        guard let source = attributedSource.mutableCopy() as? NSMutableAttributedString else { return nil }
        let range = NSRange(commentRange, in: attributedSource.string)

        switch resolution {
        case .add:
            source.insert(attributedLicense, at: 0)
        case .modify:
            source.replaceCharacters(in: range, with: attributedLicense)
        case .delete:
            source.deleteCharacters(in: range)
        case .ignore, .resolved:
            break
        }

        return source
    }

}
