//
//  LicensesManager.swift
//  CopyLib
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

@objc public final class LicenseManager: NSObject {

    @objc public static let shared = LicenseManager()
    @objc dynamic public private(set) var licenses: [License] = []

    @objc public override init() {
        super.init()

        if !FileManager.default.fileExists(atPath: licensesUrl.path) {
            do {
                try FileManager.default.createDirectory(at: licensesUrl, withIntermediateDirectories: true, attributes: [:])
            } catch {
                debugPrint(error)
            }
        }

        restoreLicenses()
    }

    @objc public func add(_ license: License) {
        precondition(!licenses.contains(license))
        licenses.append(license)
        commit(license)
    }

    @objc public func remove(_ license: License) {
        precondition(licenses.contains(license))
        guard let index = licenses.index(of: license) else { return }
        licenses.remove(at: index)
        
        do {
            try FileManager.default.removeItem(at: license.url)
        } catch {
            print("\(#function) | \(error)")
        }
    }

    @objc public func update(_ license: License) {
        guard let existing = licenses
            .first(where: { $0.identifier == license.identifier }) else {
                return
        }

        commit(existing)
    }

    @objc private func restoreLicenses() {
        let urls = try? FileManager.default.contentsOfDirectory(at: licensesUrl, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])

        let decoder = JSONDecoder()
        for url in urls ?? [] {
            do {
                let data = try Data(contentsOf: url)
                let license = try decoder.decode(License.self, from: data)
                licenses.append(license)
            } catch {
                print("Failed to restore license: \(url) | \(error)")
            }
        }
    }

    @objc public func commit(_ license: License) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(license)
            try data.write(to: license.url, options: .atomicWrite)
        } catch {
            debugPrint("\(#function) | error")
        }
    }

    @objc private var licensesUrl: URL {
        let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: caches)
            .appendingPathComponent("Licenses")
    }

}
