import Cocoa

final class ToolConsoleView: NSView {
    let operations = NSPopUpButton()
    let runButton = NSButton(title: "Run", target: nil, action: nil)
    let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
    private let progress = NSProgressIndicator()
    let console = NSTextView()
    let resultTable = NSTableView()
    private let resultScroll = NSScrollView()
    let status = NSTextField(wrappingLabelWithString: "Select a project.")
    private let form = NSStackView()
    private var controls: [String: NSControl] = [:]
    var onOperation: ((String) -> Void)?
    var onRun: (() -> Void)?
    var onCancel: (() -> Void)?
    var onBrowse: ((String, Bool) -> Void)?

    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    override init(frame: NSRect) { super.init(frame: frame); setup() }
    private func setup() {
        operations.target = self; operations.action = #selector(operationChanged)
        runButton.target = self; runButton.action = #selector(run)
        cancelButton.target = self; cancelButton.action = #selector(cancel)
        runButton.bezelStyle = .rounded; cancelButton.bezelStyle = .rounded
        progress.style = .bar; progress.isIndeterminate = true; progress.isDisplayedWhenStopped = false
        progress.widthAnchor.constraint(equalToConstant: 100).isActive = true
        let actions = NSStackView(views: [runButton, cancelButton, progress]); actions.spacing = 8
        form.orientation = .vertical; form.alignment = .leading; form.spacing = 6
        console.frame = NSRect(x: 0, y: 0, width: 600, height: 300)
        console.isEditable = false; console.isRichText = false; console.isVerticallyResizable = true
        console.isHorizontallyResizable = false; console.autoresizingMask = [.width]
        console.textContainer?.widthTracksTextView = true
        console.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        console.textContainerInset = NSSize(width: 8, height: 8)
        let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.documentView = console
        resultScroll.documentView = resultTable; resultScroll.hasVerticalScroller = true; resultScroll.isHidden = true
        resultScroll.heightAnchor.constraint(equalToConstant: 140).isActive = true
        let stack = NSStackView(views: [resultScroll, operations, form, actions, status, scroll])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false; addSubview(stack)
        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: topAnchor, constant: 12), stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12), stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12), scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)])
        for view in [resultScroll, operations, form, status, scroll] { view.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true }
    }
    func showTable(headers: [String]) {
        for column in resultTable.tableColumns { resultTable.removeTableColumn(column) }
        for (index, title) in headers.enumerated() {
            let column = NSTableColumn(identifier: .init(String(index))); column.title = title; column.width = 180; resultTable.addTableColumn(column)
        }
        resultTable.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        resultTable.usesAlternatingRowBackgroundColors = true
        resultScroll.isHidden = false
    }
    func configure(_ options: [ToolOperation], selected: String?) {
        operations.removeAllItems()
        for option in options { operations.addItem(withTitle: option.title); operations.lastItem?.representedObject = option.id }
        if let selected = selected, let item = operations.itemArray.first(where: { $0.representedObject as? String == selected }) { operations.select(item) }
    }
    var operation: String? { operations.selectedItem?.representedObject as? String }
    var values: [String: String] {
        controls.mapValues { control in
            if let popup = control as? NSPopUpButton { return popup.titleOfSelectedItem ?? "" }
            if let button = control as? NSButton { return button.state == .on ? "true" : "false" }
            return control.stringValue
        }
    }
    func setValue(_ value: String, for id: String) {
        if let popup = controls[id] as? NSPopUpButton { if let item = popup.item(withTitle: value) { popup.select(item) } }
        else if let button = controls[id] as? NSButton { button.state = value == "true" ? .on : .off }
        else { controls[id]?.stringValue = value }
    }
    func showFields(_ fields: [ToolField]) {
        let previous = values
        for view in form.arrangedSubviews { form.removeArrangedSubview(view); view.removeFromSuperview() }
        controls = [:]
        for field in fields {
            let label = NSTextField(labelWithString: field.label); label.widthAnchor.constraint(equalToConstant: 160).isActive = true
            let control: NSControl
            switch field.kind {
            case .toggle: control = NSButton(checkboxWithTitle: "", target: nil, action: nil)
            case .password: control = NSSecureTextField()
            case .choice(let choices): let popup = NSPopUpButton(); popup.addItems(withTitles: choices); control = popup
            default: control = NSTextField()
            }
            control.setAccessibilityLabel(field.label)
            controls[field.id] = control
            setValue(previous[field.id] ?? field.initial, for: field.id)
            let row = NSStackView(views: [label, control]); row.spacing = 8
            let save: Bool?
            switch field.kind { case .openFile: save = false; case .saveFile: save = true; default: save = nil }
            if let save = save {
                let button = NSButton(title: "Browse…", target: self, action: #selector(browse(_:)))
                button.identifier = .init(field.id); button.tag = save ? 1 : 0; button.bezelStyle = .rounded; row.addArrangedSubview(button)
            }
            form.addArrangedSubview(row); row.widthAnchor.constraint(equalTo: form.widthAnchor).isActive = true
        }
    }
    func running(_ running: Bool) {
        if running { progress.startAnimation(nil) } else { progress.stopAnimation(nil) }
        runButton.isEnabled = !running && operation != nil; cancelButton.isEnabled = running
        operations.isEnabled = !running
        for control in controls.values { control.isEnabled = !running }
    }
    @objc private func operationChanged() { if let operation = operation { onOperation?(operation) } }
    @objc private func run() { onRun?() }
    @objc private func cancel() { onCancel?() }
    @objc private func browse(_ sender: NSButton) { if let id = sender.identifier?.rawValue { onBrowse?(id, sender.tag == 1) } }
}
