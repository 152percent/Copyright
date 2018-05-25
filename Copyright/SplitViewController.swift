//
//  SplitViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

final class SplitViewController: NSSplitViewController {

    override var representedObject: Any? {
        didSet {
            childViewControllers.forEach { $0.representedObject = representedObject }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        minimumThicknessForInlineSidebars = 800
    }

    @IBAction public func importSourceFiles(_ sender: Any?) {
        let panel = NSOpenPanel()

        panel.title = "Select files to import"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true

        let result = panel.runModal()

        if result == .cancel {
            return
        }

        importDirectory(at: panel.url!)
    }

}

extension SplitViewController {

    internal func importDirectory(at url: URL) {
        let parser = DirectoryParser()
        _ = parser.parseDirectory(startingAt: url) { [weak self] result in
            self?.representedObject = result
        }
    }

}

// Tabbing Support
extension SplitViewController {

    @IBAction func newWindow(_ sender: Any?) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateInitialController() as! WindowController
        windowController.window?.makeKeyAndOrderFront(sender)
    }

}
