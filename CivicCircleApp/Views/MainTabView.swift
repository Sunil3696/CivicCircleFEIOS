//
//  MainTabView.swift
//  CivicCircleApp
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }

            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }

            ProfileView() // Use the fully implemented ProfileView
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .accentColor(.blue) // Tab bar tint color
    }
}

//struct EventsView: View {
//    var body: some View {
//        Text("Events Page")
//            .font(.title)
//            .foregroundColor(.gray)
//    }
//}

struct NotificationsView: View {
    var body: some View {
        Text("Notifications Page")
            .font(.title)
            .foregroundColor(.gray)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
