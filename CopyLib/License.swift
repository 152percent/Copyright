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

@objc public final class License: NSObject, Codable {

    @objc dynamic public let identifier: String
    @objc dynamic public var content: String?
    @objc dynamic public var name: String

    @objc dynamic public var url: URL {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: path)
            .appendingPathComponent("Licenses")
            .appendingPathComponent("\(identifier).license")
    }

    @objc public override init() {
        self.identifier = UUID().uuidString
        self.name = "Untitled"
        self.content = ""
        super.init()
    }

    @objc public init(name: String, content: String?) {
        self.identifier = UUID().uuidString
        self.name = name
        self.content = content
    }

    fileprivate init(identifier: String, name: String, content: String?) {
        self.identifier = identifier
        self.name = name
        self.content = content
    }

}

extension License: Comparable {

    public override func isLessThan(_ object: Any?) -> Bool {
        guard let other = object as? License else { return super.isLessThan(object) }
        return other.name < name
    }

    public static func < (lhs: License, rhs: License) -> Bool {
        return lhs.name < rhs.name
    }

}

extension License {

    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let license = object as? License else { return false }
        return license.identifier == self.identifier
    }

    public static func ==(lhs: License, rhs: License) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension License: NSCopying {

    @objc public func copy(with zone: NSZone? = nil) -> Any {
        return License(identifier: self.identifier, name: self.name, content: self.content)
    }

}
