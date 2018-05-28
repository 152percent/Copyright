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

    private var progress: Progress? {
        didSet { directoryViewController.activeProgress = progress }
    }

    private var directoryViewController: DirectoryViewController {
        return childViewControllers.compactMap({ $0 as? DirectoryViewController }).first!
    }

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
            self?.view.superview!.window!.title = panel.url?.lastPathComponent ?? "Source Files"
        }
    }

}

extension SplitViewController {

    @IBAction private func showInFinder(_ sender: Any?) {
        guard let sourceFiles = treeController.selectedObjects as? [SourceFile] else { return }
        NSWorkspace.shared.activateFileViewerSelecting(sourceFiles.urls as [URL])
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
        guard let action = menuItem.action else { return false }

        switch action {
        case #selector(toggleLineNumbers(_:)):
            menuItem.title = UserDefaults.standard[.showLineNumbers]
                ? "Hide Line Numbers"
                : "Show Line Numbers"
            return true
        case #selector(showInFinder(_:)):
            return !treeController.selectedObjects.isEmpty
        case #selector(addComment(_:)),
             #selector(modifyComment(_:)),
             #selector(deleteComment(_:)),
             #selector(ignoreComment(_:)):
            if treeController.selectedObjects.isEmpty { return false }
            let sourceFiles = treeController.selectedObjects as? [SourceFile] ?? []

            let match = sourceFiles.first {
                if $0.url.isDirectory {
                    return $0.children.first { $0.resolution.rawValue == menuItem.tag } != nil
                } else {
                    return $0.resolution.rawValue == menuItem.tag
                }
            }

            switch match {
            case .some: menuItem.state = .on
            case .none: menuItem.state = .off
            }

            return true
        default: return true
        }
    }

    @IBAction private func toggleLineNumbers(_ sender: Any?) {
        guard let controller = childViewControllers
            .compactMap({ $0 as? PreviewViewController })
            .first else { return }

        UserDefaults.standard[.showLineNumbers].toggle()
        controller.sourceTextView.toggleLineNumbers()
        controller.destinationTextView.toggleLineNumbers()
    }

    @IBAction private func addComment(_ sender: Any?) {
        resolveSelectedSourceFiles(with: .add)
    }

    @IBAction private func modifyComment(_ sender: Any?) {
        resolveSelectedSourceFiles(with: .modify)
    }

    @IBAction private func deleteComment(_ sender: Any?) {
        resolveSelectedSourceFiles(with: .delete)
    }

    @IBAction private func ignoreComment(_ sender: Any?) {
        resolveSelectedSourceFiles(with: .ignore)
    }

    private func resolveSelectedSourceFiles(with resolution: SourceFileResolution) {
        let sourceFiles = treeController.selectedObjects as? [SourceFile]

        sourceFiles?.forEach {
            $0.resolution = resolution
        }
    }

}

extension SplitViewController {

    internal func importDirectory(at url: URL) {
        let parser = DirectoryParser()

        progress = parser.parseDirectory(startingAt: url) { [weak self] result in
            self?.representedObject = result
            self?.progress = nil
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
