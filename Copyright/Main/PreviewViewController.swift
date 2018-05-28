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
    @IBOutlet private weak var resolutionButton: NSButton!

    @IBAction private func showResolutionMenu(_ sender: Any?) {
        let point = CGPoint(x: -resolutionButton.frame.midX, y: resolutionButton.frame.height + 8)
        resolutionButton.menu?.popUp(positioning: nil, at: point, in: resolutionButton)
    }

}
