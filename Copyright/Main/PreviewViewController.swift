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

        sourceTextView.lnv_setUpLineNumberView()
        destinationTextView.lnv_setUpLineNumberView()
    }

    // swiftlint:disable block_based_kvo
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
