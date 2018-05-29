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

@objc public final class DirectoryParser: NSObject {

    @objc public override init() {
        super.init()
    }

    @objc public func parseDirectory(startingAt url: URL, completion: @escaping (DirectoryResult) -> Void) -> Progress? {
        var progressCount: Int64 = 0

        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil)
        while enumerator?.nextObject() != nil { progressCount += 1 }

        let progress = Progress(totalUnitCount: progressCount)

        DispatchQueue.global().async {
            progress.becomeCurrent(withPendingUnitCount: 0)

            do {
                var fileCount = 0
                let files = try self.sourceFiles(forDirectoryAt: url, fileCount: &fileCount, progress: progress)
                let result = DirectoryResult(sourceFiles: files, fileCount: fileCount)

                DispatchQueue.main.async {
                    completion(result)
                }

                progress.resignCurrent()
            } catch {
                print("Import Failed: \(error)")
                let result = DirectoryResult(sourceFiles: [], fileCount: 0)
                progress.completedUnitCount = progressCount
                progress.resignCurrent()
                completion(result)
            }
        }

        return progress
    }

    private func sourceFiles(forDirectoryAt url: URL, fileCount: inout Int, progress: Progress) throws -> [SourceFile] {
        var urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        urls.sort { $0.path < $1.path }

        var files: [SourceFile] = []

        for url in urls {
            DispatchQueue.main.async {
                progress.completedUnitCount += 1
            }

            // only add paths that are not blacklisted
            guard !url.isBlacklisted else { continue }

            let sourceFile = SourceFile(url: url as NSURL)

            if url.isDirectory {
                let subFiles = try sourceFiles(forDirectoryAt: url, fileCount: &fileCount, progress: progress)

                // only add directories that have children
                guard !subFiles.isEmpty else { continue }

                sourceFile.add(subFiles)
                files.append(sourceFile)
            } else {
                files.append(sourceFile)

                // only increment for files (not directories)
                fileCount += 1
            }
        }

        return files
    }

}
