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
   
import AppKit
import CopyLib

public final class SourceEditorView: NSTextView {

    private lazy var indentRegex: NSRegularExpression = {
        return regex(for: "indent")
    }()

    private(set) lazy var tokenRegex: NSRegularExpression = {
        // swiftlint:disable force_try
        return try! NSRegularExpression(pattern: "</.+?/>", options: [])
    }()

    public override var string: String {
        didSet { invalidateText() }
    }

    deinit {
        removeObserver(self, forKeyPath: "textStorage")
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver(self, forKeyPath: "textStorage", options: [.initial, .new], context: nil)
    }

    // swiftlint:disable block_based_kvo
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "textStorage" {
            guard let textStorage = textStorage else { return }
            textStorage.removeLayoutManager(layoutManager!)

            let layout = SourceEditorLayoutManager()
            textStorage.addLayoutManager(layout)
            layout.addTextContainer(textContainer!)

            return
        }

        if keyPath == "contentInsets" {
            return
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        textStorage?.delegate = self
        layoutManager?.delegate = self

        usesRuler = true
        usesFindBar = true

        enclosingScrollView?.automaticallyAdjustsContentInsets = false
//        enclosingScrollView?.contentInsets.bottom = 50
//        enclosingScrollView?.contentInsets.right = enclosingScrollView?.verticalRulerView?.ruleThickness ?? 0
        lnv_setUpLineNumberView()
        invalidateText()

        layoutManager?.defaultAttachmentScaling = .scaleProportionallyDown
        enclosingScrollView?.hasVerticalRuler = UserDefaults.standard[.showLineNumbers]
    }

    public func toggleLineNumbers() {
        enclosingScrollView?.hasVerticalRuler = UserDefaults.standard[.showLineNumbers]
    }

    public func invalidateText() {
        let size: CGFloat = UserDefaults.standard[.fontSize]
        font = .userFixedPitchFont(ofSize: size)
            ?? .systemFont(ofSize: size)

        textColor = NSColor(red: 29/255, green: 133/255, blue: 25/255, alpha: 1)
        typingAttributes = [.font: font!, .foregroundColor: textColor!]
    }

    public override var font: NSFont? {
        didSet { ruler?.setNeedsDisplay(ruler?.bounds ?? .zero) }
    }

    public var ruler: NSRulerView? {
        willSet {
            if ruler != newValue {
                NotificationCenter.default.removeObserver(self, name: NSView.frameDidChangeNotification, object: self)
                NotificationCenter.default.removeObserver(self, name: NSText.didChangeNotification, object: self)
            }
        }
        didSet {
            guard let scrollView = enclosingScrollView else { return }

            ruler?.clientView = self

            scrollView.verticalRulerView = ruler
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true

            NotificationCenter.default.addObserver(self, selector: #selector(didChange(_:)),
                                                   name: NSView.frameDidChangeNotification, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(didChange(_:)),
                                                   name: NSText.didChangeNotification, object: self)
        }
    }

    public override func pasteAsRichText(_ sender: Any?) {
        pasteAsPlainText(sender)
    }

    public override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }

    @objc private func didChange(_ note: Notification) {
        ruler?.needsDisplay = true
        invalidateText()
    }

}

extension SourceEditorView {

    public override func writeSelection(to pboard: NSPasteboard, types: [NSPasteboard.PasteboardType]) -> Bool {
        let selectedString = attributedString().attributedSubstring(from: selectedRange())
        let string = NSMutableAttributedString(attributedString: selectedString)
        let range = NSRange(location: 0, length: selectedString.string.count)

        string.enumerateAttribute(.attachment, in: range, options: .reverse) { value, range, _ in
            guard let attachment = value as? TokenAttachment, let token = attachment.token else { return }
            
            var range2 = NSRange(location: 0, length: 0)
            let attributes = string.attributes(at: range.location, effectiveRange: &range2)
            let tokenString = "</\(token.string)/>"

            string.replaceCharacters(in: range, with: NSMutableAttributedString(string: tokenString))
            string.addAttributes(attributes, range: range)
        }

        pboard.clearContents()
        pboard.writeObjects([string])

        return true
    }

    public override func deleteBackward(_ sender: Any?) {
        if currentLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && currentLine.count > 1 {
            deleteToBeginningOfLine(sender)
        } else {
            super.deleteBackward(sender)
        }
    }

    private var currentLine: String {
        let range = (string as NSString).lineRange(for: selectedRange())
        return (string as NSString).substring(with: range)
    }

    @objc public override func insertNewline(_ sender: Any?) {
        let previousLine = self.currentLine
        let range = NSRange(location: 0, length: previousLine.count)

        super.insertNewline(sender)

        guard let match = indentRegex.firstMatch(in: previousLine, options: [], range: range) else { return }

        let indent = (previousLine as NSString).substring(with: match.range)
        insertText(indent, replacementRange: selectedRange())
    }

    @objc public override func insertTab(_ sender: Any?) {
        let spaces = Array(repeating: " ", count: 4)
        insertText(spaces.joined(), replacementRange: selectedRange())
    }

}

extension SourceEditorView: NSLayoutManagerDelegate {

    public func layoutManager(_ layoutManager: NSLayoutManager,
                              shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<NSRect>,
                              lineFragmentUsedRect: UnsafeMutablePointer<NSRect>,
                              baselineOffset: UnsafeMutablePointer<CGFloat>,
                              in textContainer: NSTextContainer,
                              forGlyphRange glyphRange: NSRange) -> Bool {

        let size: CGFloat = UserDefaults.standard[.fontSize]
        let font = NSFont.userFixedPitchFont(ofSize: size) ?? NSFont.systemFont(ofSize: size)
        let lineHeightMultiple: CGFloat = 1.6
        let fontLineHeight = layoutManager.defaultLineHeight(for: font)
        let lineHeight = fontLineHeight * lineHeightMultiple
        let baselineNudge = (lineHeight - fontLineHeight)
            // The following factor is a result of experimentation:
            * 0.6

        var rect = lineFragmentRect.pointee
        rect.size.height = lineHeight

        var usedRect = lineFragmentUsedRect.pointee
        usedRect.size.height = max(lineHeight, usedRect.size.height) // keep emoji sizes

        lineFragmentRect.pointee = rect
        lineFragmentUsedRect.pointee = usedRect
        baselineOffset.pointee += baselineNudge

        return true
    }

}

extension SourceEditorView: NSTextStorageDelegate {

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions,
                            range editedRange: NSRange, changeInLength delta: Int) {
        let string = textStorage.string
        let range = NSRange(location: 0, length: string.count)

        // reset attributes
//        textStorage.setAttributes(SourceFile.commentAttributes, range: range)

        let matches = tokenRegex.matches(in: string, options: [], range: range)
        guard !matches.isEmpty else { return }

        for match in matches {
            // update token attributes
            textStorage.setAttributes(SourceFile.tokenAttributes, range: match.range)
        }
    }

}

public final class SourceEditorLayoutManager: NSLayoutManager {

    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        guard let textView = firstTextView as? SourceEditorView,
            let container = textContainers.first else { return }

        let range = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        guard let string = textStorage?.mutableString.substring(with: range) else { return }

        let matches = textView.tokenRegex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        guard !matches.isEmpty else { return }

        NSColor(red: 29/255, green: 133/255, blue: 25/255, alpha: 1).withAlphaComponent(0.2).setFill()

        for match in matches {
            let rect = boundingRect(forGlyphRange: match.range, in: container)
            let path = NSBezierPath(roundedRect: rect.insetBy(dx: -2, dy: 1), xRadius: 4, yRadius: 4)
            path.fill()
        }
    }

}
