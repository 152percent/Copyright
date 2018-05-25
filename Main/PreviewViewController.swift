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

    private let normalizedFontSize: CGFloat = 12

    @IBOutlet private weak var sourceTextView: SourceEditorView!
    @IBOutlet private weak var destinationTextView: SourceEditorView!
    @IBOutlet private weak var updateButton: NSButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layer?.backgroundColor = NSColor.white.cgColor
    }

    @IBAction private func toggleScrolling(_ sender: Any?) {
        sourceTextView.enclosingScrollView?.scrollsDynamically = false
    }

    @IBAction private func showUpdateButtonMenu(_ sender: Any?) {
        let point = CGPoint(x: -updateButton.frame.midX, y: updateButton.frame.height + 8)
        updateButton.menu?.popUp(positioning: nil, at: point, in: updateButton)
    }

    @IBAction private func resetFontSize(_ sender: Any?) {
        let font = makeFont(size: normalizedFontSize, withDelta: 0)
        sourceTextView.font = font
        destinationTextView.font = font
    }

    @IBAction private func increaseFontSize(_ sender: Any?) {
        let font = makeFont(size: sourceTextView.font!.pointSize, withDelta: 1)
        sourceTextView.font = font
        destinationTextView.font = font
    }

    @IBAction private func decreaseFontSize(_ sender: Any?) {
        let font = makeFont(size: sourceTextView.font!.pointSize, withDelta: -1)
        sourceTextView.font = font
        destinationTextView.font = font
    }

    private func makeFont(size: CGFloat, withDelta delta: CGFloat) -> NSFont? {
        let descriptor = sourceTextView.font!.fontDescriptor
        let newSize = size + delta
        UserDefaults.app[.fontSize] = newSize
        return NSFont(descriptor: descriptor, size: newSize)
    }

}
