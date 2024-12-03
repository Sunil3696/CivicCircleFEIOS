//
//  Utils.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-02.
//

import Foundation

extension String {
    func formattedDate() -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return self 
    }
}
