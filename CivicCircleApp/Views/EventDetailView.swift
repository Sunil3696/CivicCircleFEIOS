import SwiftUI

struct EventDetailView: View {
    let eventId: String
    @State private var event: Event?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isJoiningEvent = false
    @State private var isCancellingParticipation = false
    @State private var isLikingEvent = false
    @State private var showCustomAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Loading Event...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let event = event {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Event Title and Image
                        VStack(alignment: .leading, spacing: 16) {
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            if let imageUrl = event.images.first, !imageUrl.isEmpty {
                                AsyncImage(url: URL(string: "http://10.0.0.185:3000\(imageUrl)")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(height: 200)
                                            .background(Color(.secondarySystemFill))
                                            .cornerRadius(10)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                            .cornerRadius(10)
                                    case .failure:
                                        Text("Failed to load image")
                                            .frame(height: 200)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(10)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }

                        // Event Details
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(icon: "location.fill", text: "Venue: \(event.venue)")
                            DetailRow(icon: "calendar", text: "Date: \(event.eventDateFrom) to \(event.eventDateTo)")
                            

                            DetailRow(icon: "phone.fill", text: "Contact: \(event.contactNumber)")
                            DetailRow(icon: "dollarsign.circle.fill", text: "Fee: \(event.eventFee)")
                            DetailRow(icon: "person.3.fill", text: "Participants: \(event.participants.count)/\(event.totalParticipantsRange.max)",
                                      textColor: event.participants.count >= event.totalParticipantsRange.max ? .red : .green)

                            Text("Description:")
                                .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading) // Align text to the left
                                    .lineSpacing(4) // Add spacing between lines for better readability
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            Text(event.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)

                        // Like and Join Buttons
                        HStack(spacing: 16) {
                            ActionButton(
                                label: "\(event.likes.count)",
                                iconName: "heart.fill",
                                iconColor: .red,
                                action: toggleLike
                            )

                            ActionButton(
                                label: "Join",
                                iconName: "person.3.fill",
                                iconColor: .blue,
                                action: joinEvent,
                                isDisabled: isJoiningEvent || event.participants.count >= event.totalParticipantsRange.max
                            )
                        }
                        .padding(.top)

                        // Cancel Button on a New Line
                        ActionButton(
                            label: "Cancel Participation",
                            iconName: "xmark.circle.fill",
                            iconColor: .red,
                            action: cancelParticipation,
                            isDisabled: isCancellingParticipation
                        )
                        .padding(.top)
                    }
                    .padding()
                }
            }

            // Custom Alert Overlay
            if showCustomAlert {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("Message")
                            .font(.headline)
                            .padding(.top)

                        Text(alertMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button(action: {
                            showCustomAlert = false
                        }) {
                            Text("OK")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(maxWidth: 300)
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchEventDetails()
        }
    }

    private func fetchEventDetails() {
        isLoading = true
        errorMessage = nil

        APIClient.shared.fetchEventById(id: eventId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvent):
                    event = fetchedEvent
                case .failure(let error):
                    errorMessage = "Failed to load event details: \(error.localizedDescription)"
                }
            }
        }
    }

    private func toggleLike() {
        guard let event = event else { return }
        isLikingEvent = true
        errorMessage = nil

        APIClient.shared.likeEvent(eventId: event.id) { result in
            DispatchQueue.main.async {
                isLikingEvent = false
                switch result {
                case .success(let updatedLikes):
                    self.event?.likes = Array(repeating: "", count: updatedLikes)
                case .failure(let error):
                    alertMessage = "Failed to like event: \(error.localizedDescription)"
                    showCustomAlert = true
                }
            }
        }
    }

    private func joinEvent() {
        guard let event = event else { return }
        isJoiningEvent = true
        errorMessage = nil

        APIClient.shared.joinEvent(eventId: event.id) { result in
            DispatchQueue.main.async {
                isJoiningEvent = false
                switch result {
                case .success:
                    fetchEventDetails()
                    alertMessage = "You have successfully joined the event."
                    showCustomAlert = true

                    // Schedule notifications
                    let currentDate = Date()
                    let eventEndDate = ISO8601DateFormatter().date(from: event.eventDateTo) ?? currentDate
                    NotificationGenerator.generateNotification(
                        title: "Event Reminder",
                        description: "Don't forget about your event: \(event.title)",
                        startDate: currentDate.addingTimeInterval(15),
                        endDate: eventEndDate
                    )
                case .failure(let error):
                    if case .networkError(let message) = error, message == "You have already joined this event" {
                        alertMessage = "You have already joined this event."
                        showCustomAlert = true
                    } else {
                        alertMessage = "Failed to join event: \(error.localizedDescription)"
                        showCustomAlert = true
                    }
                }
            }
        }
    }


   




    private func cancelParticipation() {
        guard let event = event else { return }
        isCancellingParticipation = true
        errorMessage = nil

        APIClient.shared.cancelParticipation(eventId: event.id) { result in
            DispatchQueue.main.async {
                isCancellingParticipation = false
                switch result {
                case .success:
                    fetchEventDetails()
                    alertMessage = "Successfully canceled participation."
                    showCustomAlert = true
                case .failure(let error):
                    if case .networkError(let message) = error, message == "You have not joined this event" {
                        alertMessage = "You have not joined this event."
                        showCustomAlert = true
                    } else {
                        alertMessage = "Failed to cancel participation: \(error.localizedDescription)"
                        showCustomAlert = true
                    }
                }
            }
        }
    }
}
