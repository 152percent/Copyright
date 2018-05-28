//
//  PreferencesViewController.swift
//  PreferencesTutorial
//
//  Created by Thomas on 27.12.17.
//  Copyright © 2017 Thomas Grossen. All rights reserved.
//

import Cocoa

/// Defines common behaviour for all preference panes.
open class PreferencePaneViewController: NSViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Forces the controller's view to size itself based on the Storyboard/XIB
        preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    open override func viewDidAppear() {
        super.viewDidAppear()

        // Propogates this controller's title to the window
        parent?.view.window?.title = title ?? ""
    }
    
}
