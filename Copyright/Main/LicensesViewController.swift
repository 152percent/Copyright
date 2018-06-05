/*
    2016-2018 152 Percent Ltd
    All Rights Reserved.

    NOTICE: All information contained herein is, and remains
    the property of 152 Percent Ltd and its suppliers,
    if any. The intellectual and technical concepts contained
    herein are proprietary to 152 Percent Ltd and its suppliers,
    and are protected by trade secret or copyright law.
    Dissemination of this information or reproduction of this material
    is strictly forbidden unless prior written permission is obtained
    from 152 Percent Ltd.
 */

import AppKit
import CopyLib

final class LicensesViewController: PreferencePaneViewController {

    @IBOutlet private weak var textView: SourceEditorView!
    @objc dynamic public let licenseManager = LicenseManager.shared

    @IBOutlet private weak var arrayController: LicensesArrayController!

    override func awakeFromNib() {
        super.awakeFromNib()

        // override preference
        textView.enclosingScrollView?.hasVerticalRuler = true
    }

    @IBAction private func add(_ sender: Any?) {
        let license = License(name: "Untitled", content: nil)
        licenseManager.add(license)
        arrayController.setSelectedObjects([license])
    }

    @IBAction private func remove(_ sender: Any?) {
        guard let licenses = arrayController.selectedObjects as? [License] else { return }
        licenses.forEach { licenseManager.remove($0) }
    }

    @IBAction private func update(_ sender: Any?) {
        guard let license = arrayController.selectedObjects.first as? License else { return }
        licenseManager.update(license)
    }

}

final class LicensesArrayController: NSArrayController {

    // PERF: This isn't ideal because we just iterate over all licenses and re-save them regardless of what changed
    override func commitEditing() -> Bool {
        let manager = LicenseManager.shared
        manager.licenses.forEach { manager.commit($0) }
        return true
    }

}
