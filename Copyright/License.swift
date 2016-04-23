//
//  License.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 23/04/2016.
//  Copyright © 2016 Shaps Mohsenin. All rights reserved.
//

import AppKit

// CACHES_DIR/Licenses/GUID.txt

final class License: NSObject, NSCopying, NSCoding {
  
  dynamic var identifier: String
  dynamic var name: String
  dynamic var copyright: String
  
  dynamic var attributedCopyright: NSAttributedString {
    let attributes: [String: AnyObject] = [ NSFontAttributeName: NSFont(name: "Menlo", size: 12)!, NSForegroundColorAttributeName: NSColor.labelColor() ]
    return NSAttributedString(string: copyright, attributes: attributes)
  }
  
  init?(coder aDecoder: NSCoder) {
    identifier = aDecoder.decodeObjectForKey("identifier") as! String
    name = aDecoder.decodeObjectForKey("name") as! String
    copyright = aDecoder.decodeObjectForKey("copyright") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(identifier, forKey: "identifier")
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(copyright, forKey: "copyright")
  }
  
  init(name: String, copyright: String, identifier: String = NSUUID().UUIDString) {
    self.identifier = identifier
    self.name = name
    self.copyright = copyright
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
