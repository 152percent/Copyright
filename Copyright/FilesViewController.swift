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
  
  dynamic var tree: [File]?
  dynamic var flattened: [File]?
  
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
      self.progressView.updateProgress(progress, task: "Importing", completion: "Import")
    }, completion: { [unowned self] (tree, flattened) in
      self.tree = tree
      self.flattened = flattened
      self.parser = nil
      self.outlineView.expandItem(nil, expandChildren: true)
    })
  }
  
  func updateCopyright() {
    let alert = NSAlert()
    
    alert.messageText = "Update copyright information for all files?"
    alert.informativeText = "This will modify the original file(s)"
    
    alert.addButtonWithTitle("OK")
    let cancel = alert.addButtonWithTitle("Cancel")
    
    let result = alert.runModal()
    if result == cancel.tag {
      return
    }
    
    let progress = NSProgress(totalUnitCount: Int64(flattened?.count ?? 0))
    progress.becomeCurrentWithPendingUnitCount(0)
    
    progress.cancellable = false
    progress.pausable = false
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
      if let files = self.flattened {
        for file in files {
          do {
            try file.source()?.string.writeToURL(file.url, atomically: true, encoding: NSUTF8StringEncoding)
            
            dispatch_async(dispatch_get_main_queue()) {
              progress.completedUnitCount += 1
              self.progressView.updateProgress(progress, task: "Updating", completion: "Update")
            }
          } catch {
            // folders for example would fail -- we can safely ignore these
          }
        }
      }
    }
    
    progress.resignCurrent()
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
            self.tree?.removeAtIndex(index)
          }
        }
      }
      
      treeController.rearrangeObjects()
    }
  }
  
}