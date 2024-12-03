import SwiftUI

struct EditEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var event: UserEvent
    @State private var title: String
    @State private var description: String
    @State private var contactNumber: String
    @State private var venue: String
    @State private var eventDateFrom: Date
    @State private var eventDateTo: Date
    @State private var totalParticipantsRangeMin: Int
    @State private var totalParticipantsRangeMax: Int
    @State private var eventFee: String
    @State private var selectedImage: UIImage?
    @State private var oldImageURL: String?
    @State private var isImagePickerPresented = false
    @State private var isSubmitting = false
    @State private var alertMessage: String?
    @State private var showAlert = false

    init(event: UserEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description)
        _contactNumber = State(initialValue: "")
        _venue = State(initialValue: "")
        _eventDateFrom = State(initialValue: Date())
        _eventDateTo = State(initialValue: Date())
        _totalParticipantsRangeMin = State(initialValue: 0)
        _totalParticipantsRangeMax = State(initialValue: 0)
        _eventFee = State(initialValue: "Free")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section Title
                    sectionTitle("Basic Information")
                    
                    // Title Field
                    formField(title: "Event Title", value: $title)
                    
                    // Description Field
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    
                    // Section Title
                    sectionTitle("Contact and Location")
                    
                    // Contact Number Field
                    formField(title: "Contact Number", value: $contactNumber)
                    
                    // Venue Field
                    formField(title: "Venue", value: $venue)
                    
                    // Section Title
                    sectionTitle("Event Schedule")
                    
                    // Event Dates
                    DatePicker("Start Date", selection: $eventDateFrom, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    DatePicker("End Date", selection: $eventDateTo, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    // Section Title
                    sectionTitle("Participants and Fee")
                    
                    // Participants Range
                    HStack {
                        formField(title: "Min", value: Binding(get: { "\(totalParticipantsRangeMin)" }, set: { totalParticipantsRangeMin = Int($0) ?? 0 }))
                            .keyboardType(.numberPad)
                        formField(title: "Max", value: Binding(get: { "\(totalParticipantsRangeMax)" }, set: { totalParticipantsRangeMax = Int($0) ?? 0 }))
                            .keyboardType(.numberPad)
                    }
                    
                    // Event Fee
                    Picker("Event Fee", selection: $eventFee) {
                        Text("Free").tag("Free")
                        Text("Paid").tag("Paid")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Section Title
                    sectionTitle("Event Image")
                    
                    // Image Picker
                    imagePickerSection()
                    
                    // Save Button
                    Button(action: submitEdit) {
                        Text(isSubmitting ? "Saving..." : "Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(isSubmitting ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(isSubmitting)
                }
                .padding()
            }
            .navigationTitle("Edit Event")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .onAppear(perform: populateFields)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
    }
    
    private func formField(title: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(title, text: value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    private func imagePickerSection() -> some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(8)
            } else if let oldImageURL = oldImageURL {
                AsyncImage(url: URL(string: "http://10.0.0.185:3000\(oldImageURL)")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    case .failure:
                        Text("Failed to load image")
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Button("Select Image") {
                isImagePickerPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    private func populateFields() {
        APIClient.shared.fetchEventById(id: event.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedEvent):
                    title = fetchedEvent.title
                    description = fetchedEvent.description
                    contactNumber = fetchedEvent.contactNumber
                    venue = fetchedEvent.venue
                    eventDateFrom = ISO8601DateFormatter().date(from: fetchedEvent.eventDateFrom) ?? Date()
                    eventDateTo = ISO8601DateFormatter().date(from: fetchedEvent.eventDateTo) ?? Date()
                    totalParticipantsRangeMin = fetchedEvent.totalParticipantsRange.min
                    totalParticipantsRangeMax = fetchedEvent.totalParticipantsRange.max
                    eventFee = fetchedEvent.eventFee
                    oldImageURL = fetchedEvent.images.first
                case .failure(let error):
                    alertMessage = "Failed to fetch event details: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    private func submitEdit() {
        isSubmitting = true

        let updatedEventDetails = EventDetails(
            title: title,
            description: description,
            contactNumber: contactNumber,
            venue: venue,
            eventDateFrom: eventDateFrom,
            eventDateTo: eventDateTo,
            totalParticipantsRangeMin: totalParticipantsRangeMin,
            totalParticipantsRangeMax: totalParticipantsRangeMax,
            eventFee: eventFee
        )

        APIClient.shared.updateEvent(eventId: event.id, eventDetails: updatedEventDetails, image: selectedImage) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    alertMessage = "Event updated successfully."
                    showAlert = true
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    alertMessage = "Failed to update event: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
