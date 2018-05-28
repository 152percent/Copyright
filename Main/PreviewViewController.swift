//
//  PreviewViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

public final class PreviewViewController: NSViewController {

    @IBOutlet private(set) weak var sourceTextView: SourceEditorView!
    @IBOutlet private(set) weak var destinationTextView: SourceEditorView!
    @IBOutlet private(set) weak var treeController: NSTreeController!
    @IBOutlet private weak var updateButton: NSButton!

    @IBAction private func showUpdateButtonMenu(_ sender: Any?) {
        let point = CGPoint(x: -updateButton.frame.midX, y: updateButton.frame.height + 8)
        updateButton.menu?.popUp(positioning: nil, at: point, in: updateButton)
    }

}
