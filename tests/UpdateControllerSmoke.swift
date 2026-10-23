// Isolated host for the actual Sparkle controller. It never installs an update.
import AppKit
import Combine

@main
@MainActor
final class UpdateControllerSmoke: NSObject, NSApplicationDelegate {
    private var observation: AnyCancellable?
    private var alertTimer: Timer?
    private var alertButtons: [[String]] = []

    static func main() {
        let delegate = UpdateControllerSmoke()
        let app = NSApplication.shared
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Sparkle reports HTTP failures after its modal error alert is closed.
        // Acknowledge alerts in this disposable host without approving installs.
        let timer = Timer(timeInterval: 0.2, repeats: true) { _ in
            MainActor.assumeIsolated {
                if let window = NSApp.modalWindow {
                    self.alertButtons.append(Self.buttonTitles(in: window.contentView))
                    NSApp.abortModal()
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.add(timer, forMode: .modalPanel)
        alertTimer = timer
        UserDefaults.standard.set(false, forKey: "autoCheckUpdate")
        let updater = UpdateChecker.shared
        updater.start()
        guard !updater.autoCheckEnabled else {
            finish("FAIL: old opt-out preference was not migrated")
            return
        }
        observation = updater.$status.sink { [weak self] status in
            let outcome: String?
            switch status {
            case .upToDate: outcome = "upToDate"
            case .available: outcome = "available"
            case .failed: outcome = "failed"
            default: outcome = nil
            }
            if let outcome {
                DispatchQueue.main.async { self?.finish(outcome) }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard updater.canCheckForUpdates else {
                self.finish("FAIL: cannot check after startup")
                return
            }
            // Repeat request checks the controller's in-flight guard as well.
            updater.checkForUpdates()
            updater.checkForUpdates()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.finish("FAIL: timed out")
        }
    }

    private static func buttonTitles(in view: NSView?) -> [String] {
        guard let view else { return [] }
        return ((view as? NSButton).map { [$0.title] } ?? []) + view.subviews.flatMap { buttonTitles(in: $0) }
    }

    private func finish(_ result: String) {
        var result = result
        // Case 79: the "up to date" alert must not offer Sparkle's version history.
        if result == "upToDate" {
            if alertButtons.isEmpty {
                result = "FAIL: no up-to-date alert"
            } else if alertButtons.joined().contains(where: { ["Lịch sử phiên bản", "Version History"].contains($0) }) {
                result = "FAIL: version history button shown"
            }
        }
        let environment = ProcessInfo.processInfo.environment
        let expected = environment["VKEY_SMOKE_EXPECTED"] ?? ""
        let message = result == expected ? "PASS: \(result)" : "FAIL: expected \(expected), got \(result)"
        try? message.write(toFile: environment["VKEY_SMOKE_RESULT"]!, atomically: true, encoding: .utf8)
        NSApp.terminate(nil)
    }
}
