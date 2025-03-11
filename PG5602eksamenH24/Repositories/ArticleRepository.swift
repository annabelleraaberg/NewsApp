//
//  ArticleRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 24/11/2024.
//

import Foundation
import SwiftData

@MainActor
class ArticleRepository {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveArticle(_ article: Article) {
        do {
            context.insert(article)
            try context.save()
            print("Article saved successfully: \(article.title)")
        } catch {
            print("Failed to save article: \(error)")
        }
    }
    
    func fetchSavedArticles() -> [Article] {
        do {
            print("Fetching saved articles...")
            let descriptor = FetchDescriptor<Article>(
                predicate: #Predicate<Article> { $0.isArchived == false }
            )
            let articles: [Article] = try context.fetch(descriptor)
            print("Articles fetched successfully in repository: \(articles.count)")
            return articles
        } catch {
            print("Failed to fetch saved articles in repository: \(error)")
            return []
        }
    }
    
    func updateArticle(_ article: Article, category: Category? = nil, notes: String? = nil) throws {
        if let category = category {
            article.category = category
        }
        if let notes = notes {
            article.notes = notes
        }
        article.updatedAt = Date()
        try context.save()
    }
    
    func archiveArticle(_ article: Article) {
        do {
            article.isArchived = true
            article.updatedAt = Date()
            try context.save()
            print("Archiving Article: \(article.title), Archived Status: \(article.isArchived)")
        } catch {
            print("Failed to archive article: \(error)")
        }
    }
    
    func fetchArchivedArticles() -> [Article] {
        do {
            let descriptor = FetchDescriptor<Article>(
                predicate: #Predicate<Article> { $0.isArchived == true }
            )
            let archivedArticles: [Article] = try context.fetch(descriptor)
            print("Archived articles fetched successfully: \(archivedArticles.count)")
            return archivedArticles
        } catch {
            print("Failed to fetch archived articles: \(error)")
            return []
        }
    }
    
    func restoreArticle(_ article: Article) {
        do {
            article.isArchived = false
            article.updatedAt = Date()
            try context.save()
            print("Article restored successfully: \(article.title)")
        } catch {
            print("Failed to restore article: \(error)")
        }
    }
    
    func deleteArticle(_ article: Article) {
        do {
            context.delete(article)
            try context.save()
            print("Article deleted successfully: \(article.title)")
        } catch {
            print("Failed to delete article: \(error)")
        }
    }
}
