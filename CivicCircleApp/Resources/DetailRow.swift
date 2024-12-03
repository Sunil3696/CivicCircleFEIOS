//
//  DetailRow.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//
import SwiftUI
struct DetailRow: View {
    var icon: String
    var text: String
    var textColor: Color = .primary

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
            Text(text)
                .foregroundColor(textColor)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}
