import SwiftUI

struct CreateEventView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var contactNumber: String = ""
    @State private var venue: String = ""
    @State private var eventDateFrom: Date = Date()
    @State private var eventDateTo: Date = Date()
    @State private var participantMin: String = ""
    @State private var participantMax: String = ""
    @State private var eventFee: String = "Free"
    @State private var selectedImage: UIImage? = nil
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false

    let feeOptions = ["Free", "Paid"]

    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Contact Number", text: $contactNumber)
                TextField("Venue", text: $venue)
            }

            Section(header: Text("Event Dates")) {
                DatePicker("From", selection: $eventDateFrom, displayedComponents: .date)
                DatePicker("To", selection: $eventDateTo, displayedComponents: .date)
            }

            Section(header: Text("Participants")) {
                TextField("Minimum", text: $participantMin)
                    .keyboardType(.numberPad)
                TextField("Maximum", text: $participantMax)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Fee")) {
                Picker("Event Fee", selection: $eventFee) {
                    ForEach(feeOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Event Image")) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Text("No image selected")
                        .foregroundColor(.gray)
                }

                Button("Select Image") {
                    showImagePicker = true
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                }
            }

            Button(action: createEvent) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Create Event")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSubmitting || title.isEmpty || description.isEmpty || contactNumber.isEmpty || venue.isEmpty || participantMin.isEmpty || participantMax.isEmpty || selectedImage == nil)
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func createEvent() {
        guard let image = selectedImage else { return }

        isSubmitting = true

        // Format the dates to ISO8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC

        let formattedEventDateFrom = isoFormatter.string(from: eventDateFrom)
        let formattedEventDateTo = isoFormatter.string(from: eventDateTo)

        // Updated event details with correctly formatted dates
        let eventDetails = EventDetails(
            title: title,
            description: description,
            contactNumber: contactNumber,
            venue: venue,
            eventDateFrom: eventDateFrom, // Still using Date object for local UI updates
            eventDateTo: eventDateTo,     // Using Date object for local UI updates
            totalParticipantsRangeMin: Int(participantMin) ?? 0,
            totalParticipantsRangeMax: Int(participantMax) ?? 0,
            eventFee: eventFee
        )

        print("📤 Event Details Being Sent:")
        print("Title: \(title)")
        print("Description: \(description)")
        print("Contact Number: \(contactNumber)")
        print("Venue: \(venue)")
        print("Event Date From: \(formattedEventDateFrom)")
        print("Event Date To: \(formattedEventDateTo)")
        print("Participants Min: \(participantMin)")
        print("Participants Max: \(participantMax)")

        APIClient.shared.createEventWithImage(eventDetails: eventDetails, image: image) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    alertMessage = "Event created successfully!"
                    print("✅ Event successfully created!")
                case .failure(let error):
                    alertMessage = "Failed to create event: \(error.localizedDescription)"
                    print("❌ Error creating event: \(error.localizedDescription)")
                }
                showAlert = true
            }
        }
    }

}
