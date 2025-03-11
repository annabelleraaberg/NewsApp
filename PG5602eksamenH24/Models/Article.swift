//
//  Article.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import Foundation
import SwiftData

@Model
class Source: Decodable {
    var id: String?
    var name: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    init(id: String? = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

@Model
class Article: Decodable, Identifiable {
    var id: UUID = UUID()
    var source: Source
    var author: String?
    var title: String
    var articleDescription: String?
    var url: URL
    var imageUrl: URL?
    var publishedAt: String
    var content: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    var isArchived: Bool = false
    
    @Relationship var category: Category
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.source = try container.decode(Source.self , forKey: .source)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.title = try container.decode(String.self, forKey: .title)
        self.articleDescription = try container.decodeIfPresent(String.self, forKey: .articleDescription)
        self.url = try container.decode(URL.self, forKey: .url)
        self.imageUrl = try container.decodeIfPresent(URL.self, forKey: .imageUrl)
        self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false

        self.category = Category(name: "General")
    }
    
    init (source: Source, author: String?, title: String, articleDescription: String?, url: URL, imageUrl: URL?, publishedAt: String, content: String?, notes: String?, category: Category, isArchived: Bool) {
        self.source = source
        self.author = author
        self.title = title
        self.articleDescription = articleDescription
        self.url = url
        self.imageUrl = imageUrl
        self.publishedAt = publishedAt
        self.content = content
        self.notes = notes
        self.category = category
        self.isArchived = isArchived
    }
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case articleDescription = "description"
        case url
        case imageUrl = "urlToImage"
        case publishedAt
        case content
        case notes
        case isArchived
    }
}
