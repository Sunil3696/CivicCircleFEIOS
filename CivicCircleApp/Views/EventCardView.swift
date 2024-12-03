//
//  EventCardView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//
import SwiftUI
struct EventCardView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = event.images.first, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: "http://10.0.0.185:3000\(imageUrl)")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .cornerRadius(10)
                            .clipped()
                    case .failure:
                        Text("Image Load Failed")
                            .foregroundColor(.red)
                            .frame(height: 150)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)

            Text(event.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.gray)

            HStack {
                Text("\(event.eventDateFrom) - \(event.eventDateTo)")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Text("Participants: \(event.participants.count)/\(event.totalParticipantsRange.max)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

