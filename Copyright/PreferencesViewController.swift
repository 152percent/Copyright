//
//  PreferencesViewController.swift
//  PreferencesTutorial
//
//  Created by Thomas on 27.12.17.
//  Copyright © 2017 Thomas Grossen. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        parent?.view.window?.title = title ?? ""
    }
    
}
