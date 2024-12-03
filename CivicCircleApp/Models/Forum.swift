//
//  Forum.swift
//  CivicCircleApp
//

import Foundation
struct Forum: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let images: [String]
    let creator: Creator
    let likes: [String]
    let comments: [Comment]
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, content, images, creator, likes, comments, createdAt, updatedAt
    }

    struct Creator: Codable {
        let id: String
        let email: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case email
        }
    }

    struct Comment: Codable, Identifiable {
        let id: String
        let body: String
        let date: String
        let creator: String 

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case body, date, creator
        }
    }
}
