//
//  SourceViewController.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 15/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

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
