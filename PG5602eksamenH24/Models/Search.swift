//
//  Search.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 22/11/2024.
//

import Foundation
import SwiftData

@Model
class Search: Identifiable, Codable {
    var id: UUID = UUID()
    var keyword: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    
    @Relationship var articles: [Article] = []
    
    init(keyword: String, notes: String? = nil) {
        self.keyword = keyword
        self.notes = notes
    }
    
    func updateTimestamp() {
        updatedAt = Date()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.keyword = try container.decode(String.self, forKey: .keyword)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(keyword, forKey: .keyword)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyword
        case createdAt
        case updatedAt
        case notes
    }
}
