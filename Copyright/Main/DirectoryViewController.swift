//
//  ViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Cocoa
import CopyLib

final class DirectoryViewController: NSViewController {

    @IBOutlet private(set) weak var outlineView: NSOutlineView!
    @IBOutlet private(set) weak var treeController: NSTreeController!

    @objc dynamic internal var activeProgress: Progress?

    override var representedObject: Any? {
        didSet {
            DispatchQueue.main.async {  [weak self] in
                guard let result = self?.representedObject as? DirectoryResult, result.fileCount < 100 else { return }
                self?.outlineView.expandItem(nil, expandChildren: true)
            }
        }
    }

}
