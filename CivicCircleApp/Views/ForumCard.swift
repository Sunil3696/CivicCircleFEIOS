import SwiftUI

struct ForumCardView: View {
    @State private var likesCount: Int
    let forum: Forum

    init(forum: Forum) {
        self.forum = forum
        self._likesCount = State(initialValue: forum.likes.count)
    }

    var body: some View {
        NavigationLink(destination: ForumDetailView(forum: forum)) {
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
                    Button(action: toggleLike) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(likesCount)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
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

    func toggleLike() {
        APIClient.shared.likeForumPost(postId: forum.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedLikes):
                    likesCount = updatedLikes // Update the count with the response
                case .failure(let error):
                    print("❌ Failed to toggle like: \(error.localizedDescription)")
                }
            }
        }
    }

}
