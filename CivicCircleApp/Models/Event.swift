//
//  Event.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let images: [String]
    let contactNumber: String
    let venue: String
    let eventDateFrom: String
    let eventDateTo: String
    let eventFee: String
    let status: String
    let creator: Creator
    var likes: [String]
    let participants: [String]
    let comments: [String]
    let createdAt: String
    let updatedAt: String
    let totalParticipantsRange: TotalParticipantsRange

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, images, contactNumber, venue, eventDateFrom, eventDateTo, eventFee, status, creator, likes, participants, comments, createdAt, updatedAt, totalParticipantsRange
    }
}

struct Creator: Codable {
    let id: String
    let fullName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, email
    }
}

struct TotalParticipantsRange: Codable {
    let min: Int
    let max: Int
}
