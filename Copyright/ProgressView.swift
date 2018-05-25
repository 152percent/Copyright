//
//  ProgressView.swift
//  Copyright
//
//  Created by Shaps Benkau on 25/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

final class ProgressView: NSProgressIndicator {

    private var kvoContext: UInt8 = 1

    public var progress: Progress? {
        willSet {
            if progress != nil && progress != newValue {
                removeObserver(self, forKeyPath: "fractionCompleted")
            }
        }
        didSet {
            minValue = 0
            maxValue = 1
            progress?.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: [.new, .initial], context: &kvoContext)
        }
    }

    //swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? Progress, keyPath == #keyPath(Progress.fractionCompleted) && object == progress && context == &kvoContext {
            doubleValue = progress?.fractionCompleted ?? 0
            return
        }

        return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

}
