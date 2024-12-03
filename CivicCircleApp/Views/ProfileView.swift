//
//  ProfileView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-02.
//


import SwiftUI

struct ProfileView: View {
    @State private var userName: String = "John Doe" // Placeholder for user's name
    @State private var userEmail: String = "johndoe@example.com" // Placeholder for user's email
    @State private var isLoggingOut = false // Logging out state

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Profile Avatar and Info
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)

                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    )

                    Spacer()

                    // Logout Button
                    Button(action: handleLogout) {
                        Text("Log Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 50)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadUserProfile)
        }
        .fullScreenCover(isPresented: $isLoggingOut) {
            LoginView() // Redirect to login view after logout
        }
    }

    // Function to handle logout
    private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "authToken") // Remove token from storage
        isLoggingOut = true // Trigger navigation to LoginView
    }

    // Function to load user profile (e.g., from API or local storage)
    private func loadUserProfile() {
        // Placeholder logic for loading user profile
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("User is logged in with token: \(token)")
            // Call API or load user details from storage
        } else {
            print("No user token found")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
