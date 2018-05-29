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
