import Cocoa

final class LoginSettingsView: NSView {
    let toggle = NSButton(checkboxWithTitle: "Open RnGuiTools at login", target: nil, action: nil)
    let message = NSTextField(wrappingLabelWithString: "Reading login-item status…")
    let settingsButton = NSButton(title: "Open Login Items Settings…", target: nil, action: nil)
    var onChange: ((Bool) -> Void)?
    var onOpenSettings: (() -> Void)?
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    override init(frame: NSRect) { super.init(frame: frame); setup() }
    private func setup() {
        toggle.target = self; toggle.action = #selector(changed)
        toggle.allowsMixedState = true
        settingsButton.target = self; settingsButton.action = #selector(openSettings)
        settingsButton.bezelStyle = .rounded
        let stack = NSStackView(views: [toggle, message, settingsButton])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 16
        addSubview(stack); stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: topAnchor, constant: 24), stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24), stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24), message.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -48)])
    }
    func render(state: NSControl.StateValue, message: String, busy: Bool) {
        toggle.state = state; toggle.isEnabled = !busy; self.message.stringValue = message
    }
    @objc private func changed() { onChange?(toggle.state != .off) }
    @objc private func openSettings() { onOpenSettings?() }
}
