import SwiftUI

struct ForumCardView: View {
    let forum: Forum

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text(forum.creator.email)
                        .font(.headline)

                    Text(forum.createdAt.formattedDate())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            Text(forum.title)
                .font(.title3)
                .fontWeight(.bold)

            Text(forum.content)
                .font(.body)
                .foregroundColor(.secondary)

            if let imageUrl = forum.images.first, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: "http://10.0.0.185:3000\(imageUrl)")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                    case .failure:
                        Text("Image Load Failed").foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            HStack {
                Button(action: {}) {
                    Label("\(forum.likes.count)", systemImage: "heart.fill")
                        .foregroundColor(.red)
                }

                Button(action: {}) {
                    Label("\(forum.comments.count)", systemImage: "message.fill")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
