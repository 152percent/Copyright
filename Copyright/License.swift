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

// CACHES_DIR/Licenses/GUID.txt

final class License: NSObject, NSCopying, NSCoding {
  
  dynamic var identifier: String
  dynamic var name: String
  dynamic var copyright: String
  
//  dynamic var attributedCopyright: NSAttributedString? {
//    didSet {
//      copyright = attributedCopyright?.string ?? ""
//    }
//  }
  
  init?(coder aDecoder: NSCoder) {
    identifier = aDecoder.decodeObjectForKey("identifier") as! String
    name = aDecoder.decodeObjectForKey("name") as! String
    copyright = aDecoder.decodeObjectForKey("copyright") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(identifier, forKey: "identifier")
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(copyright, forKey: "copyright")
    
//    let attributes: [String: AnyObject] = [ NSFontAttributeName: NSFont(name: "Menlo", size: 12)!, NSForegroundColorAttributeName: NSColor.labelColor() ]
//    attributedCopyright = NSAttributedString(string: copyright, attributes: attributes)
  }
  
  init(name: String, copyright: String, identifier: String = NSUUID().UUIDString) {
    self.identifier = identifier
    self.name = name
    self.copyright = copyright
    
//    let attributes: [String: AnyObject] = [ NSFontAttributeName: NSFont(name: "Menlo", size: 12)!, NSForegroundColorAttributeName: NSColor.labelColor() ]
//    attributedCopyright = NSAttributedString(string: copyright, attributes: attributes)
  }
  
  func copyWithZone(zone: NSZone) -> AnyObject {
    return License(name: self.name, copyright: self.copyright, identifier: self.identifier)
  }
  
  func children() -> [License]? {
    return nil
  }
  
  func isLeaf() -> Bool {
    return true
  }
  
  override func isEqual(object: AnyObject?) -> Bool {
    if let license = object as? License {
      return license.identifier == self.identifier
    }
    
    return false
  }
  
}

extension Array where Element: License {
  
  func indexOfLicense(withIdentifier identifier: String) -> Int? {
    for (index, license) in self.enumerate() {
      if license.identifier == identifier { return index }
    }
    
    return nil
  }
  
}