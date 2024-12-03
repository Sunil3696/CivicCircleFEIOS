
import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [Notification] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading notifications...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if notifications.isEmpty {
                    Text("No notifications available.")
                        .font(.title3)
                        .foregroundColor(.gray)
                } else {
                    List(notifications) { notification in
                        VStack(alignment: .leading) {
                            Text(notification.eventName)
                                .font(.headline)
                            Text("Event Start Date: \(formatDate(notification.eventDate))")
                                .font(.subheadline)
                            Text("Notification Created: \(formatDate(notification.createdAt))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Notifications")
            .onAppear(perform: fetchNotifications)
        }
    }

    private func fetchNotifications() {
        APIClient.shared.fetchNotifications { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedNotifications):
                    notifications = fetchedNotifications
                case .failure(let error):
                    errorMessage = "Failed to fetch notifications: \(error.localizedDescription)"
                }
            }
        }
    }

    private func formatDate(_ isoDate: String) -> String {
        var sanitizedDate = isoDate
        
        if let dotRange = sanitizedDate.range(of: ".") {
            if let zRange = sanitizedDate.range(of: "Z", range: dotRange.upperBound..<sanitizedDate.endIndex) {
                sanitizedDate.removeSubrange(dotRange.lowerBound..<zRange.lowerBound)
            }
        }

        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: sanitizedDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            print("✅ Successfully parsed date: \(date)")
            return displayFormatter.string(from: date)
        } else {
            print("❌ Failed to parse sanitized date: \(sanitizedDate)")
        }

        return isoDate
    }

}
