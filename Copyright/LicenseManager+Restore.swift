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
        let licenesUrl = Bundle.main.urls(forResourcesWithExtension: "txt", subdirectory: "Licenses")

        for sourceUrl in licenesUrl ?? [] {
            do {
                let name = sourceUrl.deletingPathExtension().lastPathComponent
                let content = try String(contentsOf: sourceUrl)
                let license = License(name: name, content: content)
                add(license)
                debugPrint("Seeded License from: \(sourceUrl) to: \(license.url)")
            } catch {
                print("Failed to seed license: \(error)")
            }
        }
    }

}
