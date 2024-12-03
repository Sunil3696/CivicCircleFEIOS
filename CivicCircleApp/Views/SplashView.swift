//
//  SplashView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//

import SwiftUI

struct SplashView: View {
    @State private var isNavigating = false // To trigger navigation
    @State private var destination: AnyView = AnyView(LoginView()) // Default destination
    @State private var showSessionExpiredMessage = false

    var body: some View {
        ZStack {
            // Splash screen content
            VStack {
                Spacer()
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Barrie Civic Circle")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                Text("Connecting Barrie, One Community at a Time")
                    .font(.subheadline)
                    .padding(.top, 5)
                Spacer()
            }

            // Show session expired message if needed
            if showSessionExpiredMessage {
                VStack {
                    Text("Session expired")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .transition(.opacity)
                .onAppear {
                    // Hide the message after 2 seconds and navigate to LoginView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSessionExpiredMessage = false
                        isNavigating = true
                    }
                }
            }

            // Navigation logic
            NavigationLink(destination: destination, isActive: $isNavigating) {
                EmptyView()
            }
        }
        .onAppear {
            // Check authentication after splash screen delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                checkAuthentication()
            }
        }
    }

    func checkAuthentication() {
        print("🔍 Checking authentication...")

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No token found. Redirecting to LoginView.")
            destination = AnyView(LoginView())
            isNavigating = true
            return
        }

        print("✅ Token found: \(token)")

        if isTokenExpired(token) {
            print("❌ Token is expired. Redirecting to LoginView.")
            // Show session expired message
            showSessionExpiredMessage = true
            destination = AnyView(LoginView())
            // Remove token from UserDefaults
            UserDefaults.standard.removeObject(forKey: "authToken")
            // Navigation will happen after message disappears
        } else {
            print("✅ Token is valid. Redirecting to MainTabView.")
            destination = AnyView(MainTabView())
            isNavigating = true
        }
    }

    func isTokenExpired(_ token: String) -> Bool {
        print("🔍 Decoding token to check expiration...")

        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("❌ Invalid token format.")
            return true
        }

        let payloadSegment = segments[1]
        print("🔍 Payload segment: \(payloadSegment)")

        // Base64 decode the payload, handling padding if necessary
        var base64String = String(payloadSegment)
        let requiredLength = (4 * ((base64String.count + 3) / 4))
        let paddingLength = requiredLength - base64String.count
        if paddingLength > 0 {
            base64String += String(repeating: "=", count: paddingLength)
        }

        guard let payloadData = Data(base64Encoded: base64String) else {
            print("❌ Failed to decode base64 payload.")
            return true
        }

        print("✅ Successfully decoded payload data.")

        guard let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            print("❌ Failed to extract 'exp' from payload.")
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        print("🔍 Token expiration date: \(expirationDate)")

        let isExpired = Date() >= expirationDate
        print(isExpired ? "❌ Token has expired." : "✅ Token is still valid.")
        return isExpired
    }
}

