//
//  Category.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 22/11/2024.
//

import Foundation
import SwiftData

@Model
class Category: Identifiable {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    
    @Relationship var articles: [Article] = []
    
    init(name: String, notes: String? = nil) {
        self.name = name
        self.notes = notes
    }
    
    func updateTimestamp() {
        updatedAt = Date()
    }
}
