//
//  UserEvent.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//

struct UserEvent: Codable, Identifiable {
    let id: String
    let fullname: String
    let createdAt: String
    let relativeTime: String
    let title: String
    let description: String
    let images: [String]
    let likesCount: Int
    let participantCount: Int
}
