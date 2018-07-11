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

#if os(iOS)
import UIKit
public typealias SystemColor = UIColor
#else
import Cocoa
public typealias SystemColor = NSColor
#endif

public extension UserDefaults {

    func register(defaults: [Key: Any]) {
        let mapped = Dictionary(uniqueKeysWithValues: defaults.map { (key, value) -> (String, Any) in
            if let color = value as? SystemColor {
                return (key.rawValue, NSKeyedArchiver.archivedData(withRootObject: color))
            } else {
                return (key.rawValue, value)
            }
        })

        register(defaults: mapped)
    }

    func set(_ value: Any?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    func set(_ color: SystemColor, forKey key: Key) {
        let data = NSKeyedArchiver.archivedData(withRootObject: color)
        set(data, forKey: key.rawValue)
    }

    func bool(forKey key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }

    func float(forKey key: Key) -> Float {
        return float(forKey: key.rawValue)
    }

    func float(forKey key: Key) -> CGFloat {
        return CGFloat(float(forKey: key) as Float)
    }

    func double(forKey key: Key) -> Double {
        return double(forKey: key.rawValue)
    }

    func url(forKey key: Key) -> URL? {
        return url(forKey: key.rawValue)
    }

    func date(forKey key: Key) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }

    func color(forKey key: Key) -> SystemColor? {
        return data(forKey: key.rawValue)
            .flatMap { NSUnarchiver.unarchiveObject(with: $0) as? SystemColor }
    }

    func value<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

}

public extension UserDefaults {

    subscript(key: Key) -> Bool {
        get { return bool(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: Key) -> Int {
        get { return integer(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: Key) -> Double {
        get { return double(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: Key) -> Float {
        get { return float(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: Key) -> CGFloat {
        get { return CGFloat(float(forKey: key) as Float) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript<T>(key: Key) -> T? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

}

extension UserDefaults {

    public struct Key: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

}
