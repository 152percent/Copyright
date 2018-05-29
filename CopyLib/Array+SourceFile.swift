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

extension Array where Element: SourceFile {

    public func resolvedSourceFiles() -> [SourceFile] {
        var files: [SourceFile] = []

        for file in self {
            if file.url.isDirectory {
                files.append(contentsOf: file.children.resolvedSourceFiles())
            } else {
                guard file.resolution != .ignore && file.resolution != .resolved else { continue }
                files.append(file)
            }
        }

        return files
    }

}
