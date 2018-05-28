//
//  SynchronizedScrollView.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit

/// NSScrollView doesn't provide a built-in `isEnabled` – so this provides one.
public class ScrollView: NSScrollView {

    @IBInspectable @objc(enabled)
    public var isEnabled: Bool = true

    public override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        } else {
            nextResponder?.scrollWheel(with: event)
        }
    }

}

/// This allows two NSScrollView's to synchronize their scrolling
public final class SynchronizedScrollView: ScrollView {

    public override class var isCompatibleWithResponsiveScrolling: Bool {
        return true
    }

    @IBOutlet private(set) weak var synchronizedScrollView: NSScrollView! {
        didSet { start() }
    }

    private func start() {
        synchronizedScrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(synchronizedScrollViewDidScroll(_:)),
                                               name: NSView.boundsDidChangeNotification,
                                               object: synchronizedScrollView.contentView)
    }

    private func stop() {
        NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification,
                                                  object: synchronizedScrollView.contentView)
    }

    @objc private func synchronizedScrollViewDidScroll(_ note: Notification) {
        guard isEnabled else { return }

        let changedContentView = note.object as! NSClipView
        let changedBoundsOrigin = changedContentView.documentVisibleRect.origin

        let currentOffset = contentView.bounds.origin
        var newOffset = currentOffset

        newOffset.y = changedBoundsOrigin.y

        if currentOffset != changedBoundsOrigin {
            contentView.scroll(to: newOffset)
        }

        reflectScrolledClipView(contentView)
    }

    public override func scrollWheel(with event: NSEvent) {
        if synchronizedScrollView.contentView.documentRect.height == contentView.documentRect.height {
            return super.scrollWheel(with: event)
        }

        if contentView.documentRect.height
            > synchronizedScrollView.contentView.documentRect.height {
            super.scrollWheel(with: event)
        } else {
            synchronizedScrollView.scrollWheel(with: event)
        }
    }

}
