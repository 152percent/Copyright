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
  
  func updateProgress(progress: NSProgress, task: String, completion: String) {
    if progress.completedUnitCount != progress.totalUnitCount && !visible {
      setVisible(true)
    }
    
    spinner.animator().doubleValue = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
    label.stringValue = progress.completedUnitCount ==
      progress.totalUnitCount ? "\(completion) Complete" : "\(task) \(progress.completedUnitCount) of \(progress.totalUnitCount)"
    
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