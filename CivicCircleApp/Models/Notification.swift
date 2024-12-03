//
//  Notification.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//
struct Notification: Codable, Identifiable {
    let id: String
    let userId: String
    let eventName: String
    let eventDate: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case eventName
        case eventDate
        case createdAt
    }
}


