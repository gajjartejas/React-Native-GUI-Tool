import Cocoa

final class ProjectInfoPanel: NSView {
    let summary = NSTextView()
    let search = NSSearchField()
    let table = NSTableView()
    let status = NSTextField(wrappingLabelWithString: "")
    var onSearch: ((String) -> Void)?
    var onShortcut: ((ProjectShortcut) -> Void)?

    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    override init(frame: NSRect) { super.init(frame: frame); setup() }

    private func setup() {
        summary.isEditable = false
        summary.isRichText = false
        summary.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        summary.textContainerInset = NSSize(width: 8, height: 8)
        summary.autoresizingMask = [.width]
        summary.textContainer?.widthTracksTextView = true
        let metadata = NSScrollView()
        metadata.hasVerticalScroller = true
        metadata.documentView = summary
        metadata.heightAnchor.constraint(equalToConstant: 200).isActive = true
        search.placeholderString = "Search dependencies, versions or scope"
        search.sendsSearchStringImmediately = true
        search.target = self
        search.action = #selector(searchChanged)
        for (id, title) in [("name", "Dependency"), ("version", "Version"), ("scope", "Scope")] {
            let column = NSTableColumn(identifier: .init(id)); column.title = title; column.width = id == "name" ? 220 : 150
            table.addTableColumn(column)
        }
        let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.documentView = table
        let buttons = ProjectShortcut.allCases.map { shortcut -> NSButton in
            let button = NSButton(title: shortcut.rawValue, target: self, action: #selector(shortcutPressed(_:)))
            button.identifier = .init(shortcut.rawValue); button.bezelStyle = .rounded; return button
        }
        let first = NSStackView(views: Array(buttons.prefix(3)))
        let second = NSStackView(views: Array(buttons.suffix(3)))
        let stack = NSStackView(views: [first, second, metadata, search, scroll, status])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 8
        addSubview(stack); stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12), stack.topAnchor.constraint(equalTo: topAnchor, constant: 12), stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)])
        for child in [metadata, search, scroll, status] { child.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true }
    }
    @objc private func searchChanged() { onSearch?(search.stringValue) }
    @objc private func shortcutPressed(_ sender: NSButton) {
        guard let key = sender.identifier?.rawValue, let shortcut = ProjectShortcut(rawValue: key) else { return }
        onShortcut?(shortcut)
    }
}
