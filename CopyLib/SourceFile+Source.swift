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
