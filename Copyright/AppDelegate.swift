//
//  AppDelegate.swift
//  Copyright
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func newWindow(_ sender: Any?) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateInitialController() as! WindowController
        windowController.window?.makeKeyAndOrderFront(sender)
    }
    
}
