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
   
import Cocoa
import CopyLib

final class DirectoryViewController: NSViewController {

    @IBOutlet private(set) weak var outlineView: NSOutlineView!
    @IBOutlet private(set) weak var treeController: NSTreeController!

    @objc dynamic internal var activeProgress: Progress?

    override var representedObject: Any? {
        didSet {
            DispatchQueue.main.async {  [weak self] in
                guard let result = self?.representedObject as? DirectoryResult, result.fileCount < 100 else { return }
                self?.outlineView.expandItem(nil, expandChildren: true)
            }
        }
    }

}
