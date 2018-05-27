//
//  Bool+Toggle.swift
//  CopyLib
//
//  Created by Shaps Benkau on 27/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import Foundation

extension Bool {

    /// Equivalent to `someBool = !someBool`
    ///
    /// Useful when operating on long chains:
    ///
    ///    myVar.prop1.prop2.enabled.toggle()
    public mutating func toggle() {
        self = !self
    }

}
