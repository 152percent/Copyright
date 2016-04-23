//
//  ViewController.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 15/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

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

