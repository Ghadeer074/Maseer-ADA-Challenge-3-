import UIKit

enum Accessibility {
    @MainActor
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    @MainActor
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
