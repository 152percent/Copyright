//
//  Notification+Observer.swift
//  Copyright
//
//  Created by Shaps Benkau on 11/06/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

public extension Notification.Name {

    func addObserver(_ observer: Any, selector: Selector, for object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self, object: object)
    }

    func observe(object: Any? = nil, queue: OperationQueue = .main, using handler: @escaping (Notification) -> Void) -> Any? {
        return NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: handler)
    }

    func observeOnce(object: Any? = nil, queue: OperationQueue = .main, using handler: @escaping (Notification) -> Void) {
        var token: Any? = nil
        token = observe(object: object, queue: queue) { _ in
            NotificationCenter.default.removeObserver(token!)
        }
    }

    func removeObserver(_ observer: Any, for object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: self, object: object)
    }

}
