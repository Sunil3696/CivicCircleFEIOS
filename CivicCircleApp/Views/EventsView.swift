//
//  EventsView.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//

import SwiftUI
struct EventsView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Events...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if events.isEmpty {
                    Text("No events available.")
                        .font(.title3)
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        ForEach(events) { event in
                            NavigationLink(destination: EventDetailView(eventId: event.id)) {
                                EventCardView(event: event)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .onAppear(perform: fetchEvents)
        }
    }

    private func fetchEvents() {
        APIClient.shared.fetchEvents { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvents):
                    if fetchedEvents.isEmpty {
                        print("✅ No events returned by the API.")
                    }
                    events = fetchedEvents
                case .failure(let error):
                    errorMessage = "Failed to load events: \(error.localizedDescription)"
                    print("❌ Error fetching events: \(error.localizedDescription)")
                }
            }
        }
    }
}
