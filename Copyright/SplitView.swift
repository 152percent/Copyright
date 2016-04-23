//
//  SplitView.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 23/04/2016.
//  Copyright © 2016 Shaps Mohsenin. All rights reserved.
//

import AppKit

final class SplitView: NSSplitView {
  
  override func drawDividerInRect(rect: NSRect) {
    NSColor.gridColor().setFill()
    NSRectFill(rect)
  }
  
}
