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

class RootViewController: NSSplitViewController {
  
  var sourceViewController: SourceViewController?
  var filesViewController: FilesViewController?
  
  deinit {
    sourceViewController?.treeController?.removeObserver(self, forKeyPath: "selection'")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    for controller in childViewControllers {
      if let controller = controller as? FilesViewController {
        filesViewController = controller
      }
      
      if let controller = controller as? SourceViewController {
        sourceViewController = controller
        sourceViewController?.treeController?.addObserver(self, forKeyPath: "selection", options: [ .Initial, .New ], context: nil)
      }
    }
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "selection" {
      if let count = sourceViewController?.treeController?.selectedObjects.count where count > 1 {
        sourceViewController?.file = nil
        sourceViewController?.placeholderLabel.stringValue = "\(count) files selected"
        return
      }
      
      if let file = sourceViewController?.treeController?.selectedObjects.first as? File {
        sourceViewController?.file = file
      } else {
        sourceViewController?.placeholderLabel.stringValue = "Select a file to preview"
      }
      
      return
    }
    
    super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
  }

}