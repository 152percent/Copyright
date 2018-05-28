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

    private weak var activeProgress: Progress? {
        didSet { directoryViewController.activeProgress = activeProgress }
    }

    public var directoryViewController: DirectoryViewController {
        return childViewControllers.compactMap({ $0 as? DirectoryViewController }).first!
    }

    public var previewViewController: PreviewViewController {
        return childViewControllers.compactMap({ $0 as? PreviewViewController }).first!
    }

    public var treeController: NSTreeController {
        return directoryViewController.treeController
    }

    override var representedObject: Any? {
        didSet {
            childViewControllers.forEach { $0.representedObject = representedObject }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        minimumThicknessForInlineSidebars = 800

        guard representedObject == nil else { return }

        DispatchQueue.main.async { [weak self] in
            self?.importDirectory(nil)
        }
    }

    @IBAction public func importDirectory(_ sender: Any?) {
        let panel = NSOpenPanel()

        panel.title = "Select a folder to import"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true

        panel.beginSheetModal(for: view.superview!.window!) { [weak self] result in
            if result == .cancel {
                return
            }

            self?.importDirectory(at: panel.url!)
        }
    }

    private func importDirectory(at url: URL) {
        representedObject = nil
        view.superview!.window!.title = url.lastPathComponent

        activeProgress = DirectoryParser().parseDirectory(startingAt: url) { [weak self] result in
            self?.representedObject = result
            self?.activeProgress = nil
        }
    }

}
