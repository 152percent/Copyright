//
//  DirectoryResult.swift
//  CopyLib
//
//  Created by Shaps Benkau on 25/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

public final class DirectoryResult: NSObject {

    @objc dynamic public let sourceFiles: [SourceFile]
    @objc dynamic public let fileCount: Int
    @objc dynamic public var selectedIndexPaths: [IndexPath]
    @objc dynamic public let sortDescriptors: [NSSortDescriptor]

    @objc public init(sourceFiles: [SourceFile], fileCount: Int) {
        self.sourceFiles = sourceFiles
        self.fileCount = fileCount

        selectedIndexPaths = sourceFiles.isEmpty ? [] : [IndexPath(index: 0) ]
        sortDescriptors = [NSSortDescriptor(key: "url.lastPathComponent", ascending: true)]
        
        super.init()
    }

}
