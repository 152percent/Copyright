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

    private let normalizedFontSize: CGFloat = 12

    private var treeController: NSTreeController {
        guard let controller = childViewControllers.compactMap({ $0 as? DirectoryViewController })
            .first else { fatalError() }
        return controller.treeController
    }

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

    @IBAction private func resetFontSize(_ sender: Any?) {
        updateFontSize(initial: normalizedFontSize, with: 0)
    }

    @IBAction private func increaseFontSize(_ sender: Any?) {
        let initial: CGFloat = UserDefaults.standard[.fontSize]
        updateFontSize(initial: initial, with: 1)
    }

    @IBAction private func decreaseFontSize(_ sender: Any?) {
        let initial: CGFloat = UserDefaults.standard[.fontSize]
        updateFontSize(initial: initial, with: -1)
    }

    private func updateFontSize(initial size: CGFloat, with delta: CGFloat) {
        let newSize = size + delta
        UserDefaults.standard[.fontSize] = newSize
    }

}

extension SplitViewController {

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard menuItem.menu?.title == "File Resolution" else { return true }
        guard let file = treeController.selectedObjects.first as? SourceFile else { return true }
        menuItem.state = menuItem.tag == file.resolution.rawValue ? .on : .off
        return true
    }

    @IBAction private func updateSourceFile(_ sender: Any?) {
        let sourceFiles = treeController.selectedObjects as? [SourceFile]
        sourceFiles?.forEach { $0.resolution = .update }
    }

    @IBAction private func ignoreSourceFile(_ sender: Any?) {
        let sourceFiles = treeController.selectedObjects as? [SourceFile]
        sourceFiles?.forEach { $0.resolution = .ignore }
    }

    @IBAction private func clearSourceFile(_ sender: Any?) {
        let sourceFiles = treeController.selectedObjects as? [SourceFile]
        sourceFiles?.forEach { $0.resolution = .clear }
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
