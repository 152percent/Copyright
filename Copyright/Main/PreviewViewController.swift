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
    @IBOutlet private weak var treeController: NSTreeController!
    @IBOutlet private weak var resolutionButton: NSButton!

    deinit {
        let keyPath = UserDefaults.Key.currentLicense.rawValue
        UserDefaults.standard.removeObserver(self, forKeyPath: keyPath)
    }

    @IBAction private func showResolutionMenu(_ sender: Any?) {
        let point = CGPoint(x: -resolutionButton.frame.midX, y: resolutionButton.frame.height + 8)
        resolutionButton.menu?.popUp(positioning: nil, at: point, in: resolutionButton)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let keyPath = UserDefaults.Key.currentLicense.rawValue
        UserDefaults.standard.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
    }

    //swiftlint:disable block_based_kvo
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let keyPath = UserDefaults.Key.currentLicense.rawValue

        if let object = object as? UserDefaults, object == .standard && keyPath == keyPath {
            guard let sourceFile = treeController.selectedObjects.first as? SourceFile else { return }
            sourceFile.willChangeValue(for: \.resolvedSource)
            sourceFile.didChangeValue(for: \.resolvedSource)
            return
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

}
