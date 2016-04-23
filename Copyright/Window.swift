//
//  Window.swift
//  Copyright
//
//  Created by Shaps Mohsenin on 15/10/2015.
//  Copyright © 2015 Shaps Mohsenin. All rights reserved.
//

import Cocoa

final class WindowController: NSWindowController {
  
  override func close() {
    super.close()
  }
  
}

final class Window: NSWindow, NSPopoverDelegate {
  
  private var rootViewController: RootViewController? {
    return contentViewController?.childViewControllers.first as? RootViewController
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    titleVisibility = .Hidden
    appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
  }
  
  @IBAction func presentLicenses(sender: AnyObject?) {
    if let controller = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("licensesPreferences") as? LicensesLibraryController,
    button = sender as? NSButton {
      let popover = NSPopover()
      popover.contentViewController = controller
      popover.behavior = .Semitransient
      popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
    }
  }

  @IBAction func importFiles(sender: AnyObject?) {
    rootViewController?.filesViewController?.importFiles()
  }
  
  @IBAction func delete(sender: AnyObject?) {
    rootViewController?.filesViewController?.removeSelectedFiles()
  }
  
}
