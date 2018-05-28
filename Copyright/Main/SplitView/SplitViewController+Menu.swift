//
//  SplitViewController+Menu.swift
//  Copyright
//
//  Created by Shaps Benkau on 28/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

// MARK: Global Actions
extension SplitViewController {

    @IBAction func newWindow(_ sender: Any?) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateInitialController() as! WindowController
        windowController.window?.makeKeyAndOrderFront(sender)
    }

    @IBAction private func toggleLineNumbers(_ sender: Any?) {
        guard let controller = childViewControllers
            .compactMap({ $0 as? PreviewViewController })
            .first else { return }

        UserDefaults.standard[.showLineNumbers].toggle()
        controller.sourceTextView.toggleLineNumbers()
        controller.destinationTextView.toggleLineNumbers()
    }

    @IBAction private func showInFinder(_ sender: Any?) {
        NSWorkspace.shared.activateFileViewerSelecting(effectedSourceFiles().urls as [URL])
    }

}

// MARK: File Resolution
extension SplitViewController {

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
        effectedSourceFiles().forEach {
            $0.resolution = resolution
        }
    }

    private func effectedSourceFiles() -> [SourceFile] {
        let clickedRow = directoryViewController.outlineView.clickedRow
        let clickedNode = directoryViewController.outlineView.item(atRow: clickedRow) as? NSTreeNode
        let selectedFiles = treeController.selectedObjects as? [SourceFile] ?? []

        guard clickedNode != nil || !selectedFiles.isEmpty else { return [] }

        if let node = clickedNode, let clickedFile = clickedNode?.representedObject as? SourceFile {
            if treeController.selectedNodes.contains(node) {
                return selectedFiles
            } else {
                return [clickedFile]
            }
        } else {
            return selectedFiles
        }
    }

}

// MARK: Menu Validation
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

            let sourceFiles = effectedSourceFiles()
            guard !sourceFiles.isEmpty else { return false }

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

}
