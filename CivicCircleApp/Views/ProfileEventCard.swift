import SwiftUI

struct ProfileEventCard: View {
    let event: UserEvent
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Event Image
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

            // Event Title
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)

            // Event Description
            Text(event.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.gray)

            // Event Details
            HStack {
                Text(event.relativeTime)
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Text("Likes: \(event.likesCount)")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text("Participants: \(event.participantCount)")
                    .font(.caption)
                    .foregroundColor(.purple)
            }

            // Buttons for Delete and Edit
            HStack(spacing: 10) {
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Delete")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                }

                NavigationLink(destination: EditEventView(event: event)) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                        Text("Edit")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
