//
//  OTPVerificationView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//

import SwiftUI

struct OTPVerificationView: View {
    let email: String                           // Passed email
    @State private var otp = ""                 // OTP input
    @State private var errorMessage: String?    // Error message for API response
    @State private var isLoading = false        // Loader state
    @State private var showSuccessPopup = false // Show success popup

    @Environment(\.dismiss) private var dismiss // Environment dismiss

    var body: some View {
        ZStack {
            // Background Color
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack {
                Spacer(minLength: 50)

                // App Icon
                Image(systemName: "key.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green.opacity(0.8))
                    .padding(.bottom, 20)

                // Title
                Text("Verify OTP")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)

                Text("Enter the OTP sent to your email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)

                // OTP Input
                VStack(spacing: 15) {
                    CustomTextField(placeholder: "Enter OTP", text: $otp, isSecure: false)
                        .keyboardType(.numberPad)

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

                // Verify OTP Button
                Button(action: verifyOTP) {
                    Text("Verify OTP")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
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
            .overlay(
                ZStack {
                    if showSuccessPopup {
                        successPopupView()
                    }
                }
            )
        }
        .navigationBarHidden(true)
    }

    func verifyOTP() {
        guard !otp.isEmpty else {
            errorMessage = "OTP cannot be empty."
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.verifyOTP(email: email, otp: otp) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    showSuccessPopup = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessPopup = false
                        dismiss() // Navigate back to login
                    }
                case .failure(let error):
                    errorMessage = (error as NSError).localizedDescription
                }
            }
        }
    }

    func successPopupView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)

            Text("Password Reset!")
                .font(.headline)
                .foregroundColor(.black)

            Text("Your new password has been emailed to you.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 300, height: 180)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
