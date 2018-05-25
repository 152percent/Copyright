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

    public enum State {
        case empty
        case idle(Int)
        case inProgress(Progress)
    }

    @IBOutlet private weak var outlineView: NSOutlineView!
    @IBOutlet private weak var progressView: ProgressView!
    @IBOutlet private weak var fileCountLabel: NSTextField!

    @objc dynamic private var activeProgress: Progress?

    override var representedObject: Any? {
        didSet {
            DispatchQueue.main.async {
                self.outlineView.expandItem(nil, expandChildren: true)
            }
        }
    }

//    private var state: State = .empty {
//        didSet { invalidateState() }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        invalidateState()
    }

//    public func invalidateState() {
//        switch state {
//        case .empty:
//            fileCountLabel.stringValue = "No files"
//            fileCountLabel.isHidden = false
//            progressView.isHidden = true
//        case let .idle(fileCount):
//            fileCountLabel.stringValue = "\(fileCount) file(s)"
//            fileCountLabel.isHidden = false
//            progressView.isHidden = true
//        case let .inProgress(progress):
//            progressView.progress = progress
//            fileCountLabel.isHidden = true
//            progressView.isHidden = false
//        }
//
////        state = .inProgress(p)
////        progressView.progress = p
//    }

}
