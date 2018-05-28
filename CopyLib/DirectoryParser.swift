/*
 Copyright © 22/05/2018 152 Percent

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

@objc public final class DirectoryParser: NSObject {

    private let disallowedPaths = [ "Human", "Machine", "Pods", "Carthage", "Build", "fastlane", "Docs" ].map { $0.lowercased() }
    private let allowedExtensions = [ "h", "m", "swift", "js" ].map { $0.lowercased() }

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
            guard !isBlacklisted(url: url) else { continue }

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

    // todo: move this to a preference with sensible defaults
    private func isBlacklisted(url: URL) -> Bool {
        for path in disallowedPaths {
            let components = url.pathComponents.map { $0.lowercased() }
            
            if components.contains(path) {
                return true
            }
        }

        if url.isDirectory && url.pathExtension.isEmpty {
            return false
        }

        return !allowedExtensions.contains(url.pathExtension)
    }

}
