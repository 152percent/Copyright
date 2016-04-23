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

import Cocoa

extension NSTreeController {
  
  func indexPathOfObject(anObject:NSObject) -> NSIndexPath? {
    return self.indexPathOfObject(anObject, nodes: self.arrangedObjects.childNodes)
  }
  
  func indexPathOfObject(anObject:NSObject, nodes:[NSTreeNode]!) -> NSIndexPath? {
    for node in nodes {
      if (anObject == node.representedObject as! NSObject)  {
        return node.indexPath
      }
      
      if (node.childNodes != nil) {
        if let path:NSIndexPath = self.indexPathOfObject(anObject, nodes: node.childNodes)
        {
          return path
        }
      }
    }
    
    return nil
  }
}

struct Licenses {
  static var Context: UInt8 = 1
}

final class LicensesLibraryController: NSViewController, NSTextFieldDelegate, NSTextViewDelegate {
  
  static var LicensesPath: String = "Copyright/Copyright.licenses"
  
  @IBOutlet var horizontalLine: NSBox!
  @IBOutlet var textView: NSTextView!
  @IBOutlet var outlineView: NSOutlineView!
  @IBOutlet weak var treeController: NSTreeController!
  @IBOutlet var copyrightPlaceholder: NSTextField!
  @IBOutlet var licensesPlaceholder: NSTextField!
  
  dynamic var sortDescriptors: [NSSortDescriptor] = {
    return [ NSSortDescriptor(key: "name", ascending: true) ]
  }()
  
  private(set) dynamic var licenses = [License]()
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if context == &Licenses.Context && keyPath == "selection" {
      licensesPlaceholder.hidden = treeController.arrangedObjects.count > 0
      copyrightPlaceholder.hidden = treeController.selectedObjects.count == 1
      textView.editable = treeController?.selectedObjects.count == 1
      
      NSUserDefaults.standardUserDefaults().setInteger(treeController.selectionIndexPath?.indexAtPosition(0) ?? 0, forKey: "current-index")
      
      if let license = treeController.selectedObjects.first as? License {
        NSUserDefaults.standardUserDefaults().setObject(license.copyright, forKey: "copyright")
      } else {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "copyright")
      }
      
      textView.textStorage?.font = NSFont(name: "Menlo", size: 12)!
      
      return
    }
    
    super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    prepareLicenses()
    
    let index = NSUserDefaults.standardUserDefaults().integerForKey("current-index")
    
    if index < treeController.arrangedObjects.count {
      let indexPath = NSIndexPath(indexes: [index], length: 1)
      treeController.setSelectionIndexPath(indexPath)
    }
    
    self.treeController?.addObserver(self, forKeyPath: "selection", options: [ .Initial, .New ], context: &Licenses.Context)
  }
  
  func prepareLicenses() {
    NSUserDefaults.standardUserDefaults().registerDefaults([ "first-run": true ])
    
    if NSUserDefaults.standardUserDefaults().boolForKey("first-run") {
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "first-run")
      restore()
      return
    }
    
    guard let caches: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else {
      fatalError("Cannot access caches directory!")
    }
    
    let path = caches.stringByAppendingPathComponent(LicensesLibraryController.LicensesPath)
    if let licenses = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [License] {
      self.licenses = licenses
    }
  }
  
  override func controlTextDidEndEditing(obj: NSNotification) {
    treeController.rearrangeObjects()
    save()
  }
  
  func textDidEndEditing(notification: NSNotification) {
    treeController.rearrangeObjects()
    save()
  }
  
  @IBAction func add(sender: AnyObject?) {
    let license = License(name: "Untitled", copyright: "/*\n\nCopyright goes here...\n\n*/")
    licenses.append(license)
    
    if let indexPath = treeController.indexPathOfObject(license) {
      treeController.setSelectionIndexPath(indexPath)
    }
    
    save()
  }
  
  @IBAction func delete(sender: AnyObject?) {
    if let selectedLicenses = treeController.selectedObjects as? [License] {
      for license in selectedLicenses {
        if let index = licenses.indexOf(license) {
          licenses.removeAtIndex(index)
          
          if index > 0 {
            treeController.setSelectionIndexPath(NSIndexPath(index: index - 1))
          }
        }
      }
      
      save()
    }
  }
  
  @IBAction func restore(sender: AnyObject?) {
    let alert = NSAlert()
    
    let ok = alert.addButtonWithTitle("OK")
    alert.addButtonWithTitle("Cancel")
    
    alert.messageText = "Are you sure you want to restore defaults?"
    alert.informativeText = "This will delete all of your presets, and restore the defaults."
    
    let result = alert.runModal()
    
    if result == ok.tag {
      restore()
    }
  }
  
  @IBAction func redo(sender: AnyObject?) {
    textView.undoManager?.redo()
  }
  
  private func restore() {
    do {
      for path: NSString in NSBundle.mainBundle().pathsForResourcesOfType("txt", inDirectory: "Licenses") {
        let name = NSString(string: path.stringByDeletingPathExtension).lastPathComponent
        let copyright = try NSString(contentsOfFile: path as String, encoding: NSUTF8StringEncoding)
        let license = License(name: name, copyright: copyright as String, identifier: name)
        
        if let index = licenses.indexOfLicense(withIdentifier: name) {
          licenses.removeAtIndex(index)
        }
        
        licenses.append(license)
      }
      
      save()
    } catch {
      print(error)
    }
  }
  
  private func save() {
    guard let caches: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else {
      fatalError("Cannot access caches directory!")
    }
    
    let path = caches.stringByAppendingPathComponent(LicensesLibraryController.LicensesPath)
    NSKeyedArchiver.archiveRootObject(licenses, toFile: path)
  }
  
}