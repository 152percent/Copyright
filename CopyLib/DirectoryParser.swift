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

    @objc public override init() {
        super.init()
    }

    @objc public func parseDirectory(startingAt url: URL, completion: @escaping (DirectoryResult) -> Void) -> Progress? {
        var progressCount: Int64 = 0

        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil)
        while enumerator?.nextObject() != nil { progressCount += 1 }

        let progress = Progress(totalUnitCount: progressCount)

        DispatchQueue.global().async {
            do {
                var fileCount = 0
                let files = try self.sourceFiles(forDirectoryAt: url, fileCount: &fileCount, progress: progress)
                let result = DirectoryResult(sourceFiles: files, fileCount: fileCount)

                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("Import Failed: \(error)")
                let result = DirectoryResult(sourceFiles: [], fileCount: 0)
                progress.completedUnitCount = progressCount
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
            let sourceFile = SourceFile(url: url as NSURL)
            files.append(sourceFile)

            DispatchQueue.main.async {
                progress.completedUnitCount += 1
            }

            if url.isDirectory {
                sourceFile.add(try sourceFiles(forDirectoryAt: url, fileCount: &fileCount, progress: progress))
            } else {
                fileCount += 1
            }
        }

        return files
    }

    @objc public func parseDirectory2(startingAt URL: URL, completion: @escaping (DirectoryResult) -> Void) -> Progress? {
        /*
         - root
           - child1
           - child2
             - sub-root
                 - child1
                 - child1
             - sub-root
                 - child1
                 - child1
         - root
             - child1
         */

        let enumerator = FileManager.default
            .enumerator(at: URL, includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsPackageDescendants, .skipsHiddenFiles, .skipsSubdirectoryDescendants]) { url, error in
            print("Failed for: \(url) -- \(error)")
            return true
        }

        var URLs = [NSURL]()
        var tree = [SourceFile]()
        var flattened = [SourceFile]()

        while let url = enumerator?.nextObject() as? NSURL {
            let folder = url
            URLs.append(folder)
        }

        if URLs.count == 0 {
            let result = DirectoryResult(sourceFiles: [], fileCount: 0)
            completion(result)
            return nil
        }

        let progress = Progress(totalUnitCount: Int64(URLs.count))
        progress.becomeCurrent(withPendingUnitCount: 0)

        progress.isCancellable = false
        progress.isPausable = false

        DispatchQueue.global(qos: .default).async {
            let enumerator = FileManager.default.enumerator(at: URL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsPackageDescendants, .skipsHiddenFiles]) { url, error in
                print("Failed for: \(url) -- \(error)")
                return true
            }

            func updateProgress() {
                DispatchQueue.main.async {
                    progress.completedUnitCount += 1
                }
            }

            var directories = [String: SourceFile]()

            while let url = enumerator?.nextObject() as? NSURL {
                var isDirectory: AnyObject?
                //swiftlint:disable force_try
                try! url.getResourceValue(&isDirectory, forKey: .isDirectoryKey)
                let directory = isDirectory as? Bool ?? false

                // check if we should skip, don't forget to increment the progress anyway
                if self.shouldSkip(url: url, directory) {
                    updateProgress()
                    continue
                }

                guard let path = url.path else {
                    updateProgress()
                    continue
                }

                let file = SourceFile(url: url)
                let parent = directories[NSString(string: path).deletingLastPathComponent]

                if directory {
                    directories[path] = file
                }

                if parent != nil {
                    parent?.add(file)
                    flattened.append(file)
                } else {
                    tree.append(file)
                    flattened.append(file)
                }

                updateProgress()
            }

            DispatchQueue.main.async {
                let (files, count) = tree.cleaned
                let result = DirectoryResult(sourceFiles: files, fileCount: count)
                completion(result)
                progress.resignCurrent()
            }
        }

        return progress
    }

    // todo: move this to a preference with sensible defaults
    private func shouldSkip(url: NSURL, _ isDirectory: Bool) -> Bool {
        let disallowedPaths = [ "Human", "Machine", "Pods", ] //"Carthage", "Build" ]
        let allowedExtensions = [ "h", "m", "swift" ]

        for path in disallowedPaths {
            if let components = url.pathComponents {
                if components.contains(path) {
                    return true
                }
            }
        }

        if isDirectory && url.pathExtension?.count == 0 {
            return false
        }

        if let ext = url.pathExtension {
            return !allowedExtensions.contains(ext)
        }

        return false
    }

}
