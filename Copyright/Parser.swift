//
//  Parser.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 11/04/2016.
//  Copyright © 2016 Shaps Mohsenin. All rights reserved.
//

import AppKit

final class Parser: NSObject {
  
  func parseDirectory(startingAt URL: NSURL, progressBlock: (NSProgress) -> Void, completion: ([File]) -> Void) {
    let enumerator = NSFileManager.defaultManager().enumeratorAtURL(URL, includingPropertiesForKeys: [ NSURLIsDirectoryKey ], options: [.SkipsPackageDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
      print("Failed for: \(url) -- \(error)")
      return true
    }
    
    var URLs = [NSURL]()
    var files = [File]()
    
    while let url = enumerator?.nextObject() as? NSURL {
      let folder = url
      URLs.append(folder)
    }
  
    if URLs.count == 0 {
      completion(files)
      return
    }
    
    let progress = NSProgress(totalUnitCount: Int64(URLs.count ?? 0))
    progress.becomeCurrentWithPendingUnitCount(0)
    
    progress.cancellable = true
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
        } else {
          files.append(file)
        }

        updateProgress()
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        completion(files)
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
