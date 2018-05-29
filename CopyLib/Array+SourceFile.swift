//
//  Array+SourceFile.swift
//  CopyLib
//
//  Created by Shaps Benkau on 29/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

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
