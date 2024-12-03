import SwiftUI

struct ForumDetailView: View {
    @State private var forum: Forum
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var newComment: String = "" // Input for new comment
    @State private var isSubmittingComment = false // Loading state for comment submission

    init(forum: Forum) {
        self._forum = State(initialValue: forum)
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Post Title
                        Text(forum.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // Post Content
                        Text(forum.content)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        // Post Image
                        if let imageUrl = forum.images.first, !imageUrl.isEmpty {
                            AsyncImage(url: URL(string: "http://10.0.0.185:3000\(imageUrl)")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 200)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                        .padding()
                                case .failure:
                                    Text("Failed to load image")
                                        .foregroundColor(.red)
                                        .padding()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }

                        // Like and Comment Section
                        HStack {
                            HStack(spacing: 5) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(forum.likes.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 5) {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.blue)
                                Text("\(forum.comments.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        Divider()

                        // Comments Header
                        Text("Comments")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 10)

                        // Comments Section
                        if forum.comments.isEmpty {
                            Text("No comments yet. Be the first to comment!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                        } else {
                            ForEach(forum.comments) { comment in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(comment.body)
                                        .font(.body)
                                    Text("By: \(comment.creator)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }

                        Divider()

                        // Comment Input Section
                        VStack {
                            HStack {
                                TextField("Write a comment...", text: $newComment)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)

                                Button(action: postComment) {
                                    if isSubmittingComment {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                                            .cornerRadius(8)
                                    }
                                }
                                .disabled(newComment.isEmpty || isSubmittingComment)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            fetchForumDetails()
        }
        .navigationTitle("Forum Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fetchForumDetails() {
        isLoading = true
        errorMessage = nil

        APIClient.shared.fetchForumById(id: forum.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let updatedForum):
                    forum = updatedForum
                case .failure(let error):
                    errorMessage = "Failed to load forum details: \(error.localizedDescription)"
                }
            }
        }
    }

    private func postComment() {
        isSubmittingComment = true
        APIClient.shared.addCommentToForum(postId: forum.id, body: newComment) { result in
            DispatchQueue.main.async {
                isSubmittingComment = false
                switch result {
                case .success:
                    newComment = "" // Clear the input field
                    fetchForumDetails() // Refresh the forum details
                case .failure(let error):
                    errorMessage = "Failed to post comment: \(error.localizedDescription)"
                }
            }
        }
    }
}
