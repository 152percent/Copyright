//
//  AppearancePreferencesViewController.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 15/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

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

final class LicensesLibraryController: NSViewController, NSTextFieldDelegate {
  
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
