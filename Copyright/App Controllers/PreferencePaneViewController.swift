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

/// Defines common behaviour for all preference panes.
open class PreferencePaneViewController: NSViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Forces the controller's view to size itself based on the Storyboard/XIB
        preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    open override func viewDidAppear() {
        super.viewDidAppear()

        // Propogates this controller's title to the window
        parent?.view.window?.title = title ?? ""
    }
    
}
