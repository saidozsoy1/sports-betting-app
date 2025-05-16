//
//  Sport.swift
//  Sports Betting App
//
//  Created by Said Ozsoy on 16.05.2025.
//

import Foundation

// MARK: - Models

struct Sport: Codable {
    let key: String
    let group: String
    let title: String
    let description: String?
    let active: Bool
    let has_outrights: Bool
}
