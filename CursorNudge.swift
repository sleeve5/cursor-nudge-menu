import AppKit
import CoreGraphics

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let interval: TimeInterval = 180
    private let enabledKey = "FeatureEnabled"

    private var statusItem: NSStatusItem!
    private var enableItem: NSMenuItem!
    private var disableItem: NSMenuItem!
    private var timer: Timer?
    private var isEnabled = false

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        applyState()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }

    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()

        enableItem = NSMenuItem(
            title: "开启移动",
            action: #selector(enableFeature),
            keyEquivalent: ""
        )
        enableItem.target = self
        menu.addItem(enableItem)

        disableItem = NSMenuItem(
            title: "关闭移动",
            action: #selector(disableFeature),
            keyEquivalent: ""
        )
        disableItem.target = self
        menu.addItem(disableItem)

        statusItem.menu = menu
    }

    @objc private func enableFeature() {
        setEnabled(true)
    }

    @objc private func disableFeature() {
        setEnabled(false)
    }

    private func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: enabledKey)
        applyState()
    }

    private func applyState() {
        timer?.invalidate()
        timer = nil

        if isEnabled {
            requestEventAccessIfNeeded()
            let nextTimer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
                self?.nudgeCursor()
            }
            RunLoop.main.add(nextTimer, forMode: .common)
            timer = nextTimer
        }

        enableItem.state = isEnabled ? .on : .off
        disableItem.state = isEnabled ? .off : .on

        let symbolName = isEnabled ? "cursorarrow.rays" : "cursorarrow"
        let fallbackName = "cursorarrow"
        let image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: "鼠标微移"
        ) ?? NSImage(
            systemSymbolName: fallbackName,
            accessibilityDescription: "鼠标微移"
        )
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.toolTip = isEnabled ? "鼠标微移：已开启" : "鼠标微移：已关闭"
    }

    private func requestEventAccessIfNeeded() {
        if !CGPreflightPostEventAccess() {
            CGRequestPostEventAccess()
        }
    }

    private func nudgeCursor() {
        guard let sourceEvent = CGEvent(source: nil) else {
            return
        }

        let before = sourceEvent.location
        let after = CGPoint(x: before.x, y: before.y + 1)
        let moveEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: after,
            mouseButton: .left
        )
        moveEvent?.post(tap: .cghidEventTap)
    }
}
