//
//  CGContext.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Cocoa

public extension CGContext {

    public static var current: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }

}
