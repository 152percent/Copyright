//
//  UserDefaults.swift
//  CopyLib
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {

    public func register(defaults: [Key: Any]) {
        let mapped = Dictionary(uniqueKeysWithValues: defaults.map { key, value in (key.rawValue, value) })
        register(defaults: mapped)
    }

    public func set(_ value: Any?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    public func bool(forKey key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }

    public func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }

    public func float(forKey key: Key) -> Float {
        return float(forKey: key.rawValue)
    }

    public func float(forKey key: Key) -> CGFloat {
        return CGFloat(float(forKey: key) as Float)
    }

    public func double(forKey key: Key) -> Double {
        return double(forKey: key.rawValue)
    }

    public func url(forKey key: Key) -> URL? {
        return url(forKey: key.rawValue)
    }

    public func date(forKey key: Key) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    public func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }

    public func value<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

}

extension UserDefaults {

    public subscript(key: Key) -> Bool {
        get { return bool(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> Int {
        get { return integer(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> Double {
        get { return double(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> Float {
        get { return float(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> CGFloat {
        get { return CGFloat(float(forKey: key) as Float) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> String? {
        get { return string(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> URL? {
        get { return url(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: Key) -> Date? {
        get { return date(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript<T>(key: Key) -> T? {
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
