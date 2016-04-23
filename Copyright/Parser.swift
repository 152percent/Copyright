/*
  Copyright © 23/04/2016 Snippex

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

import AppKit

final class Parser: NSObject {
  
  func parseDirectory(startingAt URL: NSURL, progressBlock: (NSProgress) -> Void, completion: (tree: [File], flattened: [File]) -> Void) {
    let enumerator = NSFileManager.defaultManager().enumeratorAtURL(URL, includingPropertiesForKeys: [ NSURLIsDirectoryKey ], options: [.SkipsPackageDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
      print("Failed for: \(url) -- \(error)")
      return true
    }
    
    var URLs = [NSURL]()
    var tree = [File]()
    var flattened = [File]()
    
    while let url = enumerator?.nextObject() as? NSURL {
      let folder = url
      URLs.append(folder)
    }
  
    if URLs.count == 0 {
      completion(tree: tree, flattened: tree)
      return
    }
    
    let progress = NSProgress(totalUnitCount: Int64(URLs.count ?? 0))
    progress.becomeCurrentWithPendingUnitCount(0)
    
    progress.cancellable = false
    progress.pausable = false
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [unowned self] in
      let enumerator = NSFileManager.defaultManager().enumeratorAtURL(URL, includingPropertiesForKeys: [ NSURLIsDirectoryKey ], options: [.SkipsPackageDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
        print("Failed for: \(url) -- \(error)")
        return true
      }
      
      func updateProgress() {
        dispatch_async(dispatch_get_main_queue()) {
          progress.completedUnitCount += 1
          progressBlock(progress)
        }
      }
      
      var directories = [String: File]()
      
      while let url = enumerator?.nextObject() as? NSURL {
        var isDirectory: AnyObject?
        try! url.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
        let directory = isDirectory as? Bool ?? false
        
        // check if we should skip, don't forget to increment the progress anyway
        if self.shouldSkip(url, directory) {
          updateProgress()
          continue
        }
        
        guard let path = url.path else {
          updateProgress()
          continue
        }
        
        let file = File(url: url)
        let parent = directories[NSString(string: path).stringByDeletingLastPathComponent]
        
        if directory {
          directories[path] = file
        }

        if parent != nil {
          parent?.addFile(file)
          flattened.append(file)
        } else {
          tree.append(file)
          flattened.append(file)
        }

        updateProgress()
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        completion(tree: tree, flattened: flattened)
      }
    }
    
    progress.resignCurrent()
  }
  
  private func shouldSkip(url: NSURL, _ isDirectory: Bool) -> Bool {
    let disallowedPaths = [ "Human", "Machine", "Pods" ]
    let allowedExtensions = [ "h", "m", "swift" ]
    
    for path in disallowedPaths {
      if let components = url.pathComponents {
        if components.contains(path) {
          return true
        }
      }
    }
    
    if isDirectory && url.pathExtension?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
      return false
    }
    
    if let ext = url.pathExtension {
      return !allowedExtensions.contains(ext)
    }
    
    return false
  }
  
}