//
//  ForumModel.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//
import Foundation

struct ForumModel: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let images: [String]
    let creator: Creator
    let likes: [String]
    let comments: [Comment]
    let createdAt: String
    let updatedAt: String

    struct Creator: Codable {
        let id: String
        let email: String
    }

    struct Comment: Codable {
        let body: String
        let date: String
        let creator: String
    }
}
