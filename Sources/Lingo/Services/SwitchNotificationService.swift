import UserNotifications

struct SwitchNotificationService {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    func show(appName: String, sourceName: String) {
        let content = UNMutableNotificationContent()
        content.title = L10n.string("notification.title")
        content.body = L10n.format("notification.body %@ %@", appName, sourceName)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
