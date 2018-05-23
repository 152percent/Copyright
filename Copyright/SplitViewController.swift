//
//  SplitViewController.swift
//  Copyright
//
//  Created by Shaps Benkau on 23/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

final class SplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        minimumThicknessForInlineSidebars = 700
    }

}
