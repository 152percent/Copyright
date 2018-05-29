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
