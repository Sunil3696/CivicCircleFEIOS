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

            // Navigation logic
            NavigationLink(destination: destination, isActive: $isNavigating) {
                EmptyView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                checkAuthentication()
            }
        }
    }

    func checkAuthentication() {
        if let _ = UserDefaults.standard.string(forKey: "authToken") {
            destination = AnyView(MainTabView()) // Navigate to Home (with TabBar)
        } else {
            destination = AnyView(LoginView()) // Navigate to Login
        }
        isNavigating = true // Trigger navigation
    }
}
