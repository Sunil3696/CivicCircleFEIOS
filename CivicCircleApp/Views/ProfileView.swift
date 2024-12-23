import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var userEvents: [UserEvent] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedOut = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading profile...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // User Information Section
                            if let user = user {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("User Information")
                                        .font(.headline)
                                        .padding(.bottom, 5)

                                    Text("Name: \(user.fullName)")
                                    Text("Email: \(user.email)")
                                    Text("Phone: \(user.phone)")
                                    Text("Address: \(user.address)")
                                    Text("Joined: \(formatDate(user.createdAt))")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }

                            // Add Event Button
                            NavigationLink(destination: CreateEventView()) {
                                Text("Create New Event")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.vertical)

                            // User Events Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your Events")
                                    .font(.headline)
                                    .padding(.bottom, 5)

                                ForEach(userEvents) { event in
                                    ProfileEventCard(event: event, onDelete: { deleteEvent(event) })
                                }
                            }

                            // Logout Button
                            Button(action: logout) {
                                Text("Logout")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(
                NavigationLink(destination: LoginView(), isActive: $isLoggedOut) {
                    EmptyView()
                }
                .hidden()
            )
            .onAppear {
                fetchUserProfile()
            }
        }
    }

    private func fetchUserProfile() {
        isLoading = true
        errorMessage = nil

        // Fetch user info
        APIClient.shared.fetchUserInfo { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                    self.fetchUserEvents()
                case .failure(let error):
                    self.errorMessage = "Failed to load user info: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    private func fetchUserEvents() {
        APIClient.shared.fetchUserEvents { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let events):
                    self.userEvents = events
                case .failure(let error):
                    self.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
                }
            }
        }
    }

    private func deleteEvent(_ event: UserEvent) {
        APIClient.shared.deleteEvent(eventId: event.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    userEvents.removeAll { $0.id == event.id }
                    alertMessage = "Event deleted successfully."
                    showAlert = true
                case .failure(let error):
                    alertMessage = "Failed to delete event: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    private func logout() {
        print("🚪 Logging out user...")
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Reset the root view to LoginView
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("❌ Unable to access window scene.")
            return
        }
        if let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: LoginView())
            window.makeKeyAndVisible()
        }
    }

    private func formatDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return isoDate
    }
}
