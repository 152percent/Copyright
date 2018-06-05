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

final class SplitViewController: NSSplitViewController {

    private var activeProgress: Progress? {
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
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        guard representedObject == nil else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
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

    @IBAction public func updateLicenses(_ sender: Any?) {
        guard let result = representedObject as? DirectoryResult else { return }
        let resolved = result.sourceFiles.resolvedSourceFiles()

        guard resolved.count > 0 else {
            let error = NSError(domain: "com.152percent.license", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Nothing to update"
            ])

            let alert = NSAlert(error: error)
            alert.alertStyle = .informational
            alert.informativeText = "Resolve some files before running an update."
            alert.runModal()

            return
        }

        let alert = NSAlert()

        alert.alertStyle = .critical
        alert.messageText = "Update Licenses"
        alert.informativeText = "This task cannot be undone. Ensure your files are backed before continuing."

        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        updateLicenses(resolved: resolved)
    }

    private func updateLicenses(resolved: [SourceFile]) {
        activeProgress = Progress(totalUnitCount: Int64(resolved.count))

        DispatchQueue.global().async { [weak self] in
            self?.activeProgress?.becomeCurrent(withPendingUnitCount: 0)

            for sourceFile in resolved {
                DispatchQueue.main.async {
                    self?.activeProgress?.completedUnitCount += 1
                }

                do {
                    try sourceFile.resolvedSource?.string.write(to: sourceFile.url as URL, atomically: true, encoding: .utf8)

                    DispatchQueue.main.async {
                        sourceFile.willChangeValue(for: \.attributedSource)
                        sourceFile.resolution = .resolved
                        sourceFile.didChangeValue(for: \.attributedSource)
                    }
                } catch {
                    print("Update license failed for: \(sourceFile.url.path!)")
                }
            }

            self?.activeProgress?.resignCurrent()

            DispatchQueue.main.async {
                self?.activeProgress = nil
            }
        }
    }

}
