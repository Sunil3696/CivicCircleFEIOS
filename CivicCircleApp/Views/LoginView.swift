//
//  LoginView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//
import SwiftUI

struct LoginView: View {
    @State private var email = ""               // Email input
    @State private var password = ""            // Password input
    @State private var errorMessage: String?    // Error message for API response
    @State private var isLoading = false        // Loader state
    @State private var navigateToHome = false   // Navigation state

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 50)

                    // Animated Icon (Optional)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom, 20)

                    // Title
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 5)

                    Text("Please log in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)

                    // Form Card
                    VStack(spacing: 20) {
                        // Email Field
                        CustomTextField(placeholder: "Email Address", text: $email, isSecure: false)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        // Password Field
                        CustomTextField(placeholder: "Password", text: $password, isSecure: true)

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)

                    // Login Button
                    Button(action: login) {
                        Text("Login")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                    // Loading Indicator
                    if isLoading {
                        ProgressView()
                            .padding()
                    }

                    // Reset Password Link
                    NavigationLink(destination: RequestResetView()) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.top, 10)

                    Spacer()

                    // Register Link
                    NavigationLink(destination: RegisterView()) {
                        Text("Don't have an account? Register")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true) // Hide navigation bar on login
            .fullScreenCover(isPresented: $navigateToHome) {
                HomeView() // Navigate to HomeView on successful login
            }
        }
    }

    // Login Function
    func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    navigateToHome = true // Navigate to Home on success
                case .failure(let error):
                    // Display the localized error message
                    errorMessage = (error as NSError).localizedDescription
                }
            }
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool

    var body: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        } else {
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
