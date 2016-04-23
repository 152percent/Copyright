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

func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
  let string = NSMutableAttributedString(attributedString: lhs)
  string.appendAttributedString(NSAttributedString(string: "\n\n"))
  string.appendAttributedString(rhs)
  return string
}

final class File: NSObject, NSCopying {
  
  static var dateFormatter: NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    return formatter
  }
  
  @objc var parent: File?
  @objc var files = [File]()
  
  var isDirectory: Bool {
    var isDirectory: AnyObject?
    try! url.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
    return isDirectory as? Bool ?? false
  }
  
  func copyWithZone(zone: NSZone) -> AnyObject {
    let object = File(url: url)
    object.files = files
    return object
  }
  
  var image: NSImage {
    if isDirectory {
      return NSWorkspace.sharedWorkspace().iconForFileType(NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
    }
    
    switch url.pathExtension! {
    case "h": return NSImage(named: "header")!
    case "m": return NSImage(named: "implementation")!
    default: return NSImage(named: "swift")!
    }
  }
  
  private(set) var url: NSURL
  
  private func attributes(copyright: Bool) -> [String: AnyObject] {
    let font = copyright ? NSFont(name: "Menlo-Italic", size: 13)! : NSFont(name: "Menlo", size: 13)!
    let color = copyright ? NSColor.labelColor() : NSColor.secondaryLabelColor()
    return [ NSFontAttributeName: font, NSForegroundColorAttributeName: color ]
  }
  
  private func sourceWithoutCopyright(string: String, separator: String) -> String {
    let range = NSString(string: string).rangeOfString(separator)
    
    if range.location == NSNotFound {
      return string
    }
    
    return NSString(string: string).substringFromIndex(range.location + range.length)
  }
  
  dynamic func source() -> NSAttributedString? {
    do {
      let date = File.dateFormatter.stringFromDate(NSDate())
      let company = NSUserDefaults.standardUserDefaults().stringForKey("company") ?? "#CompanyName#"
      var string = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      
      if string.hasPrefix("/*") {
        string = sourceWithoutCopyright(string, separator: "*/\n\n")
      }
      
      if string.hasPrefix("//") {
        string = sourceWithoutCopyright(string, separator: "//\n\n")
      }
      
      var copyrightString = NSUserDefaults.standardUserDefaults().stringForKey("copyright")
      
      if copyrightString == nil {
        if let copyrightURL = NSBundle.mainBundle().URLForResource("Apache", withExtension: "txt", subdirectory: "Licenses") {
          copyrightString = try NSString(contentsOfURL: copyrightURL, encoding: NSUTF8StringEncoding).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
      }
      
      copyrightString = copyrightString?.stringByReplacingOccurrencesOfString("#Date#", withString: date)
      copyrightString = copyrightString?.stringByReplacingOccurrencesOfString("#CompanyName#", withString: company)
      
      let copyright = NSAttributedString(string: copyrightString!, attributes: attributes(true))
      let source = NSAttributedString(string: string, attributes: attributes(false))
      
      return copyright + source
    } catch {
      print("Couldn't read source: \(error)")
    }
    
    return nil
  }
  
  init(url: NSURL) {
    self.url = url
  }
  
  func addFile(file: File) {
    file.parent = self
    files.append(file)
  }
  
  func children() -> [File] {
    return files
  }
  
  func isLeaf() -> Bool {
    return files.count == 0
  }
  
}