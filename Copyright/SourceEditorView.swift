//
//  SourceEditorView.swift
//  Copyright
//
//  Created by Shaps Benkau on 24/05/2018.
//  Copyright © 2018 152percent Ltd. All rights reserved.
//

import AppKit
import CopyLib

public final class SourceEditorView: NSTextView {

    // </token/>
    private lazy var tokenRegex: NSRegularExpression = {
        // swiftlint:disable force_try
        return try! NSRegularExpression(pattern: "</.+?/>", options: [])
    }()

    public override var string: String {
        didSet { invalidateText() }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        textStorage?.delegate = self

        usesRuler = true
        usesFindBar = true
        lnv_setUpLineNumberView()
        invalidateText()

        enclosingScrollView?.hasVerticalRuler = UserDefaults.standard[.showLineNumbers]
    }

    public func toggleLineNumbers() {
        enclosingScrollView?.hasVerticalRuler = UserDefaults.standard[.showLineNumbers]
    }

    public func invalidateText() {
        let size: CGFloat = UserDefaults.standard[.fontSize]
        font = NSFont.userFixedPitchFont(ofSize: size)
            ?? NSFont.systemFont(ofSize: size)

        textColor = NSColor.secondaryLabelColor

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7

        defaultParagraphStyle = style
        typingAttributes = [.paragraphStyle: style, .font: font!, .foregroundColor: textColor!]
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

            NotificationCenter.default.addObserver(self, selector: #selector(didChange(_:)), name: NSView.frameDidChangeNotification, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(didChange(_:)), name: NSText.didChangeNotification, object: self)
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

extension SourceEditorView: NSTextStorageDelegate {

    public func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let string = textStorage.string as NSString
        let lineRange = string.lineRange(for: editedRange)
        let line = string.substring(with: lineRange)
        let matches = tokenRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

        let tokens = matches
            .map { $0.range }
            .map { line[Range($0, in: line)!] }
            .map { $0.dropFirst(2) }
            .map { $0.dropLast(2) }

        let cells = tokens
            .map { String($0) }
            .map { TokenCell(textCell: $0) }

        let attachments = cells.map { cell -> NSTextAttachment in
            let attachment = NSTextAttachment()
            attachment.attachmentCell = cell
            return attachment
        }

        let tokenStrings = attachments
            .map { NSAttributedString(attachment: $0) }

        for (match, string) in zip(matches, tokenStrings).reversed() {
            textStorage.replaceCharacters(in: match.range, with: string)
        }
    }

}
