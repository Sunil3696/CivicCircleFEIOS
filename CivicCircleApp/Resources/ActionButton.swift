//
//  ActionButton.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//
import SwiftUI
struct ActionButton: View {
    var label: String
    var iconName: String
    var iconColor: Color
    var action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                Text(label)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray.opacity(0.5) : Color.white)
            .foregroundColor(isDisabled ? .gray : .primary)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .disabled(isDisabled)
    }
}

