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
