//
//  LineNumberRulerView.swift
//  LineNumber
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import Foundation

extension NSTextView {

    private var lineNumberView: LineNumberRulerView? {
        return enclosingScrollView?.verticalRulerView as? LineNumberRulerView
    }
    
    func prepareLineNumbers() {
        font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)

        if let scrollView = enclosingScrollView {
            scrollView.rulersVisible = true
            scrollView.hasVerticalRuler = true
            scrollView.verticalRulerView = LineNumberRulerView(textView: self)
        }
        
        postsFrameChangedNotifications = true

        NSTextStorage.didProcessEditingNotification.addObserver(self, selector: #selector(lnv_invalidate), for: self)
        NSView.frameDidChangeNotification.addObserver(self, selector: #selector(lnv_invalidate), for: self)
        NSText.didChangeNotification.addObserver(self, selector: #selector(lnv_invalidate), for: self)

        addObserver(self, forKeyPath: "font", options: [.initial, .new], context: nil)
        addObserver(self, forKeyPath: "string", options: [.initial, .new], context: nil)
    }

    // swiftlint:disable block_based_kvo
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? NSTextView, object == self && (keyPath == "font" || keyPath == "string") {
            lnv_invalidate()
            return
        }

        // seems to be a Mojave bug?
        if keyPath == "contentInsets" { return }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    @objc func lnv_invalidate() {
        lineNumberView?.font = font
        lineNumberView?.needsDisplay = true
    }
}

private final class LineNumberRulerView: NSRulerView {

    private let padding: CGFloat = 8

    fileprivate var font: NSFont? {
        didSet { self.needsDisplay = true }
    }
    
    fileprivate init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        self.font = textView.font ?? .userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)
        self.clientView = textView
        self.ruleThickness = 40
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        // we manually draw the background to avoid the automatic separator AppKit inserts otherwise
        drawBackground(in: rect)
        drawLineNumbers(in: rect)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return clientView
    }

}

private extension LineNumberRulerView {

    private func drawLineNumber(_ lineNumber: Int, in rect: CGRect) {
        guard let textView = clientView as? NSTextView else { return }

        var attributes = textView.typingAttributes
        attributes[.foregroundColor] = NSColor.tertiaryLabelColor

        let string = NSAttributedString(string: "\(lineNumber)", attributes: attributes)
        let x = ruleThickness - padding - string.size().width

        var rect = rect
        rect.origin.x = x

        string.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])
    }

    func drawBackground(in rect: CGRect) {
        NSColor.textBackgroundColor.setFill()
        rect.fill()
    }

    func drawLineNumbers(in rect: CGRect) {
        guard let textView = clientView as? NSTextView,
            let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer,
            let textStorage = textView.textStorage,
            textStorage.length > 0 else { return }

        let string = textView.string as NSString
        let insetHeight = textView.textContainerInset.height
        let relativePoint: CGPoint = convert(.zero, from: textView)

        let visibleRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        let firstVisibleIndex = layoutManager.characterIndexForGlyph(at: visibleRange.location)

        let test = "some\nthing\n"
        _ = test.lineCount
        // the line number for the first visible line
        var lineNumber = textView.string.lineCount(in: NSRange(location: 0, length: firstVisibleIndex)) + 1
        // the line index in the visible range
        var lineIndex = visibleRange.location

        // while lineNumber is a visible line
        while lineIndex < NSMaxRange(visibleRange) {
            let charIndex = layoutManager.characterIndexForGlyph(at: lineIndex)
            let charRange = string.lineRange(for: NSRange(location: charIndex, length: 0))
            let glyphRange = layoutManager.glyphRange(forCharacterRange: charRange, actualCharacterRange: nil)

            var glyphIndexForCurrentLine = lineIndex

            // this will be 0 unless we're dealing with a wrapped line
            var lineIndexForCurrentLine = 0

            while glyphIndexForCurrentLine < NSMaxRange(charRange) {
                var effectiveRange = NSRange()
                var lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForCurrentLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)

                let y = ceil(lineRect.minY + relativePoint.y + insetHeight)
                lineRect.origin.y = y

                // if this is the first line of a glyph range (i.e. not any wrapped glyphs) then draw the line number
                if lineIndexForCurrentLine == 0 {
                    drawLineNumber(lineNumber, in: lineRect)
                } // else draw some other indicator, i.e. ◦

                // if the line wraps, increment
                lineIndexForCurrentLine += 1
                glyphIndexForCurrentLine = NSMaxRange(effectiveRange)
            }

            lineNumber += 1
            lineIndex = NSMaxRange(glyphRange)
        }

        guard layoutManager.extraLineFragmentTextContainer != nil else { return }

        var lineRect = layoutManager.extraLineFragmentRect
        let y = ceil(lineRect.minY + relativePoint.y + insetHeight)
        lineRect.origin.y = y
        drawLineNumber(lineNumber, in: lineRect)
    }

}
