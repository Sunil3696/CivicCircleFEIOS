//
//  User.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//

struct User: Codable {
    let id: String
    let fullName: String
    let email: String
    let phone: String
    let address: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, email, phone, address, createdAt, updatedAt
    }
}
