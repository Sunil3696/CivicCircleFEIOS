//
//  ResetPasswordView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//

import SwiftUI

struct RequestResetView: View {
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var navigateToOTP = false    

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 50)

                    // App Icon
                    Image(systemName: "envelope.open.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom, 20)

                    // Title
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 5)

                    Text("Enter your email to receive an OTP")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)

                    // Email Input
                    VStack(spacing: 15) {
                        CustomTextField(placeholder: "Email Address", text: $email, isSecure: false)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)

                    // Request OTP Button
                    Button(action: requestReset) {
                        Text("Request OTP")
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

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToOTP) {
                OTPVerificationView(email: email)
            }
        }
    }

    func requestReset() {
        guard validateEmail() else { return }

        isLoading = true
        errorMessage = nil

        APIClient.shared.requestPasswordReset(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    navigateToOTP = true
                case .failure(let error):
                    errorMessage = (error as NSError).localizedDescription
                }
            }
        }
    }

    func validateEmail() -> Bool {
        if email.isEmpty {
            errorMessage = "Email field cannot be empty."
            return false
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            errorMessage = "Please enter a valid email address."
            return false
        }

        return true
    }
}
