import SwiftUI

struct HomeView: View {
    @State private var forums: [Forum] = []
    @State private var newPostTitle: String = ""
    @State private var newPostContent: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isLoading = false
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Forum Creation Section
                    VStack(spacing: 10) {
                        Text("Create a Post")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

                        VStack(spacing: 10) {
                            TextField("Enter a title...", text: $newPostTitle)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)

                            TextField("Write your forum or post here...", text: $newPostContent)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)

                            HStack {
                                Button(action: { isImagePickerPresented = true }) {
                                    Label("Photo", systemImage: "photo.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 10)

                                Button(action: { isImagePickerPresented = true }) {
                                    Label("Camera", systemImage: "camera.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 10)
                            }

                            Button(action: createPost) {
                                Text("Post")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    // Recent Active Forums Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Active Forums")
                            .font(.headline)
                            .padding(.horizontal)

                        if isLoading {
                            ProgressView("Loading forums...")
                        } else if forums.isEmpty {
                            Text("No forums available.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(forums) { forum in
                                ForumCardView(forum: forum)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear(perform: fetchForums)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary) 
            }
            .alert(isPresented: $isAlertPresented) {
                Alert(title: Text("Message"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }

    func fetchForums() {
        isLoading = true
        APIClient.shared.fetchForums { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let forums):
                    self.forums = forums
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    isAlertPresented = true
                }
            }
        }
    }

    func createPost() {
        guard !newPostTitle.isEmpty, !newPostContent.isEmpty else {
            alertMessage = "Please fill in all fields."
            isAlertPresented = true
            return
        }

        APIClient.shared.createForumPost(title: newPostTitle, content: newPostContent, image: selectedImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    alertMessage = "Post created successfully!"
                    newPostTitle = ""
                    newPostContent = ""
                    selectedImage = nil
                    fetchForums()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                }
                isAlertPresented = true
            }
        }
    }
}
