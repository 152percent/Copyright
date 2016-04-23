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

class SourceViewController: NSViewController {
  
  @IBOutlet weak var placeholderLabel: NSTextField!
  @IBOutlet var textView: NSTextView!
  
  private dynamic var source: NSAttributedString?
  dynamic var file: File? {
    didSet {
      update()
    }
  }
  
  deinit {
    NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "company")
    NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "copyright")
  }
  
  var rootViewController: RootViewController? {
    return parentViewController as? RootViewController
  }
  
  dynamic var treeController: NSTreeController? {
    return rootViewController?.filesViewController?.treeController
  }
  
  dynamic var isEmpty: Bool {
    return source?.string.isEmpty ?? true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "company", options: [ .New ], context: nil)
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "copyright", options: [ .New, .Initial ], context: nil)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "company" || keyPath == "copyright" {
      update()
      return
    }
    
    super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
  }
  
  private func update() {
    source = file?.isDirectory ?? true ? nil : file?.source()
    textView.enclosingScrollView?.contentInsets.bottom = 40
  }
  
}