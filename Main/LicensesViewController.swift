//
//  LicensesViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

final class LicensesController: NSArrayController {

    // PERF: This isn't ideal because we just iterate over all licenses and re-save them regardless of what changed
    override func commitEditing() -> Bool {
        let manager = LicenseManager.shared
        manager.licenses.forEach { manager.commit($0) }
        return true
    }

}

final class LicensesViewController: PreferencesViewController {

    @IBOutlet private weak var textView: SourceEditorView!
    @objc dynamic public let licenseManager = LicenseManager.shared

    @IBOutlet private weak var arrayController: LicensesController!
    @objc dynamic private let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // override preference
        textView.enclosingScrollView?.hasVerticalRuler = true
    }

    @IBAction private func add(_ sender: Any?) {
        let license = License(name: "Untitled", content: nil)
        licenseManager.add(license)

        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            self?.licenseManager.remove(license)
        }

        arrayController.setSelectedObjects([license])
    }

    @IBAction private func remove(_ sender: Any?) {
        guard let licenses = arrayController.selectedObjects as? [License] else { return }
        licenses.forEach { licenseManager.remove($0) }

        undoManager?.registerUndo(withTarget: self) { [weak self] _ in
            licenses.forEach { self?.licenseManager.add($0) }
        }
    }

    @IBAction private func update(_ sender: Any?) {
        guard let license = arrayController.selectedObjects.first as? License else { return }
        licenseManager.update(license)
    }

}
