//
//  View.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 16/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

import Cocoa
import InkKit
import SwiftLayout

@IBDesignable
class ProgressView: NSView {
  
  @IBOutlet private weak var positionConstraint: NSLayoutConstraint!
  @IBOutlet private weak var spinner: NSProgressIndicator!
  @IBOutlet private weak var label: NSTextField!
  private var visible = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    wantsLayer = true
    spinner.usesThreadedAnimation = false
    spinner.minValue = 0
    spinner.maxValue = 1
    spinner.animator().doubleValue = 0
  }
  
  func updateProgress(progress: NSProgress) {
    if progress.completedUnitCount != progress.totalUnitCount && !visible {
      setVisible(true)
    }
    
    spinner.animator().doubleValue = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
    label.stringValue = progress.completedUnitCount ==
      progress.totalUnitCount ? "Import Complete" : "Importing \(progress.completedUnitCount) of \(progress.totalUnitCount)"
    
    if progress.completedUnitCount == progress.totalUnitCount && visible {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
        self.setVisible(false)
      }
    }
  }
  
  private func setVisible(visible: Bool) {
    self.visible = visible
    NSAnimationContext.currentContext().duration = visible ? 0 : 0.2
    positionConstraint.animator().constant = visible ? 44 : 0
  }
  
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)
    
    NSColor.gridColor().setFill()
    NSRectFill(dirtyRect)
  }
  
}
