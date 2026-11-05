import Cocoa

final class SystemInfoView: NSView {
    let reportTextView = NSTextView()
    let refreshButton = NSButton(title: "Refresh / Run Diagnostics", target: nil, action: nil)
    let copyButton = NSButton(title: "Copy Diagnostics Report", target: nil, action: nil)
    let statusLabel = NSTextField(wrappingLabelWithString: "")
    private let progress = NSProgressIndicator()
    var onRefresh: (() -> Void)?
    var onCopy: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let title = NSTextField(labelWithString: "System Info")
        title.font = .boldSystemFont(ofSize: 18)
        let description = NSTextField(wrappingLabelWithString: "Inspect your React Native development environment. Missing tools include setup guidance.")
        description.textColor = .secondaryLabelColor
        refreshButton.target = self
        refreshButton.action = #selector(refresh)
        copyButton.target = self
        copyButton.action = #selector(copyReport)
        refreshButton.bezelStyle = .rounded
        copyButton.bezelStyle = .rounded
        progress.style = .spinning
        progress.controlSize = .small
        progress.isDisplayedWhenStopped = false
        let actions = NSStackView(views: [refreshButton, copyButton, progress])
        actions.spacing = 8
        actions.alignment = .centerY

        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        reportTextView.isEditable = false
        reportTextView.isSelectable = true
        reportTextView.isRichText = false
        reportTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        reportTextView.textContainerInset = NSSize(width: 12, height: 12)
        reportTextView.autoresizingMask = [.width]
        reportTextView.isHorizontallyResizable = false
        reportTextView.isVerticallyResizable = true
        reportTextView.textContainer?.widthTracksTextView = true
        reportTextView.setAccessibilityLabel("Environment diagnostics report")
        scroll.documentView = reportTextView
        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabelColor
        for child in [title, description, actions, scroll, statusLabel] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
        }
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            description.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            description.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actions.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 12),
            actions.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            actions.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            scroll.topAnchor.constraint(equalTo: actions.bottomAnchor, constant: 12),
            scroll.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scroll.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -8),
            statusLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    func render(report: String, status: String, isScanning: Bool, canCopy: Bool) {
        reportTextView.string = report
        statusLabel.stringValue = status
        refreshButton.isEnabled = !isScanning
        copyButton.isEnabled = canCopy
        if isScanning { progress.startAnimation(nil) } else { progress.stopAnimation(nil) }
    }

    @objc private func refresh() { onRefresh?() }
    @objc private func copyReport() { onCopy?() }
}
