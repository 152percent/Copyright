//
//  FilesViewController.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 15/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

import Cocoa

class FilesViewController: NSViewController {
  
  private var parser: Parser?
  @IBOutlet weak var treeController: NSTreeController!
  @IBOutlet var outlineView: NSOutlineView!
  @IBOutlet var progressView: ProgressView!
  @IBOutlet var button: NSButton!
  
  var rootViewController: RootViewController? {
    return parentViewController as? RootViewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let attributes = [ NSForegroundColorAttributeName: NSColor.tertiaryLabelColor(), NSFontAttributeName: NSFont.systemFontOfSize(14) ]
    button.attributedTitle = NSAttributedString(string: "Choose files...", attributes: attributes)
  }
  
  dynamic var files: [File]?
  func importFiles() {    
    if parser != nil {
      return
    }
    
    let panel = NSOpenPanel()
    
    panel.title = "Select files to import"
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    
    let result = panel.runModal()
    
    if result == NSModalResponseCancel {
      return
    }
    
    parser = Parser()
    
    guard let URL = panel.URL else {
      assert(panel.URL != nil, "No URL found")
      return
    }
    
    parser?.parseDirectory(startingAt: URL, progressBlock: { [unowned self] progress in
      self.progressView.updateProgress(progress)
    }, completion: { [unowned self] files in
      self.files = files
      self.parser = nil
      self.outlineView.expandItem(nil, expandChildren: true)
    })
  }
  
  @IBAction func showInFinder(sender: AnyObject?) {
    if let file = sender?.representedObject as? File {
      NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([file.url])
    }
  }
  
  func removeSelectedFiles() {
    if let files = treeController.selectedObjects as? [File] {
      for file in files {
        if let parent = file.parent, index = parent.files.indexOf(file) {
          parent.files.removeAtIndex(index)
          
          let indexPath = treeController.selectionIndexPath?.indexPathByRemovingLastIndex()
          treeController.setSelectionIndexPath(indexPath)
        } else {
          if let index = files.indexOf(file) {
            self.files?.removeAtIndex(index)
          }
        }
      }
      
      treeController.rearrangeObjects()
    }
  }
  
}
