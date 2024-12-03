//
//  RegisterView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//
import SwiftUI

struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var showSuccessPopup = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 50)

                    // App Icon
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom, 20)

                    // Title
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 5)

                    Text("Join us and get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)

                    // Form Card
                    VStack(spacing: 15) {
                        // Full Name Field
                        CustomTextField(placeholder: "Full Name", text: $fullName, isSecure: false)

                        // Email Field
                        CustomTextField(placeholder: "Email Address", text: $email, isSecure: false)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        // Password Field
                        CustomTextField(placeholder: "Password", text: $password, isSecure: true)

                        // Phone Field
                        CustomTextField(placeholder: "Phone Number", text: $phone, isSecure: false)
                            .keyboardType(.phonePad)

                        // Address Field
                        CustomTextField(placeholder: "Address", text: $address, isSecure: false)
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

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.top, 5)
                    }

                    // Register Button
                    Button(action: register) {
                        Text("Register")
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

                    // Navigate to Login
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Already have an account? Login")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.bottom, 30)
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
    }

    // Registration Function
    func register() {
        guard validateInputs() else {
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.register(fullName: fullName, email: email, password: password, phone: phone, address: address) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    // Show the popup and navigate to login after 2 seconds
                    showSuccessPopup = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessPopup = false
                        dismiss()
                    }
                case .failure(let error):
                    errorMessage = (error as NSError).localizedDescription
                }
            }
        }
    }

    // Input Validation
    func validateInputs() -> Bool {
        if fullName.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty || address.isEmpty {
            errorMessage = "All fields are required."
            return false
        }

        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address."
            return false
        }

        if !isValidPhone(phone) {
            errorMessage = "Please enter a valid phone number."
            return false
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }

        return true
    }

    // Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // Phone Validation
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,15}$" // Allows 10 to 15 digits
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }

    // Custom Success Popup
    func successPopupView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)

            Text("Registration Successful!")
                .font(.headline)
                .foregroundColor(.black)

            Text("You can now log in.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 250, height: 150)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
