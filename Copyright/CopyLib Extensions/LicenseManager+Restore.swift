//
//  LicenseManager+Restore.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation
import CopyLib

extension LicenseManager {

    public func seedLicenses() {
        let licenesUrl = Bundle.main.urls(forResourcesWithExtension: "license", subdirectory: "Licenses")
        let decoder = JSONDecoder()

        for sourceUrl in licenesUrl ?? [] {
            do {
                let data = try Data(contentsOf: sourceUrl)
                let license = try decoder.decode(License.self, from: data)
                guard !licenses.contains(license) else { continue }
                add(license)
                debugPrint("Restored License from: \(sourceUrl) to: \(license.url)")
            } catch {
                print("Failed to seed license: \(error)")
            }
        }
    }

}
