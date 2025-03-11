//
//  ArticlesViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var savedArticles: [Article] = []
    @Published var archivedArticles: [Article] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var country: String = "us"
    @Published var selectedCategory: Category?
    
    private var articleRepository: ArticleRepository
    private var categoryRepository: CategoryRepository
    
    private var iso8601Formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    init(articleRepository: ArticleRepository, categoryRepository: CategoryRepository) {
        self.articleRepository = articleRepository
        self.categoryRepository = categoryRepository
        loadSavedArticles()
    }
    
    func loadSavedArticles() {
        self.savedArticles = articleRepository.fetchSavedArticles()
        print("Saved articles loaded: \(self.savedArticles.count)")
    }
    
    func saveArticle(_ article: Article, category: Category, note: String?) {
        guard !category.name.isEmpty else {
            print("Error: Cannot save article without a valid category.")
            return
        }
        
        article.category = category
        
        // Check if the article is already in the category's list, add if not
        if !category.articles.contains(where: { $0.id == article.id }) {
            category.articles.append(article)
        }
        
        // Add the article to the category's article list if it's not already present
        if !categoryRepository.getAllCategories().contains(where: { $0.id == category.id }) {
            categoryRepository.saveCategory(category)
        }
        
        if let note = note, !note.isEmpty {
            article.notes = note
        }
        
        articleRepository.saveArticle(article)
        print("Article saved successfully: \(article.title) with category: \(category.name)")
    }
    
    func isArticleSaved(_ article: Article) -> Bool {
        savedArticles.contains(where: { $0.id == article.id })
    }
    
    func formattedCreatedAt(for article: Article) -> String {
        return dateFormatter.string(from: article.createdAt)
    }
    
    func formattedUpdatedAt(for article: Article) -> String {
        return dateFormatter.string(from: article.updatedAt)
    }
    
    func formattedPublishedAt(for article: Article) -> String {
        if let date = iso8601Formatter.date(from: article.publishedAt) {
            return dateFormatter.string(from: date)
        } else {
            return article.publishedAt
        }
    }
    
    // Updates the category of a particular article
    func updateCategoryForArticle(_ article: Article) {
        let updatedCateogry = article.category
        if !categoryRepository.getAllCategories().contains(where: {$0.id == updatedCateogry.id}) {
            categoryRepository.saveCategory(updatedCateogry)
        }
        do {
            try articleRepository.updateArticle(article, category: updatedCateogry)
            print("Category updated successfully for article: \(article.title)")
        } catch {
            print("Failed to update category for article: \(article.title), error:\(error)")
        }
        loadSavedArticles()
    }
    
    // Updates the category name in the database and applies the changes to all articles with that category
    func updateCategoryName(_ category: Category, newName: String) {
        let trimmedNewName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedNewName.isEmpty else {
            print("Category name cannot be empty")
            return
        }
        
        // Update category name in repository
        categoryRepository.updateCategoryName(category, newName: trimmedNewName)
        
        // Updates all articles with old category name to the new name
        let articlesToUpdate = articles.filter { $0.category.id == category.id }
        for article in articlesToUpdate {
            article.category.name = trimmedNewName
            articleRepository.saveArticle(article)
        }
        loadSavedArticles()
    }
    
    func editArticleNote(_ article: Article, _ newNote: String?) -> String {
        guard let updatedNote = newNote?.trimmingCharacters(in: .whitespaces), !updatedNote.isEmpty else {
            return "Please enter a valid note"
        }
        
        article.notes = updatedNote
        articleRepository.saveArticle(article)
        loadSavedArticles()
        
        return ""
    }
    
    func deleteNote(_ article: Article) {
        article.notes = nil
        articleRepository.saveArticle(article)
        loadSavedArticles()
    }
    
    func loadArchivedArticles() {
        self.archivedArticles = articleRepository.fetchArchivedArticles()
        print("Archived articles loaded: \(self.archivedArticles.count)")
    }
    
    func archiveArticle(_ article: Article) {
        articleRepository.archiveArticle(article)
        loadSavedArticles()
        loadArchivedArticles()
        print("Article archived: \(article.title)")
        print("Updated saved articles count: \(savedArticles.count)")
        print("Updated archived articles count: \(archivedArticles.count)")
    }
    
    func isArticleArchived(_ article: Article) -> Bool {
        archivedArticles.contains(where: { $0.id == article.id })
    }
    
    func restoreArticle(_ article: Article) {
        articleRepository.restoreArticle(article)
        loadArchivedArticles()
        loadSavedArticles()
        print("Article restored: \(article.title)")
    }
    
    func deleteArticle(_ article: Article) {
        articleRepository.deleteArticle(article)
        loadSavedArticles()
        loadArchivedArticles()
        self.errorMessage = nil
        print("Article deleted: \(article.title)")
    }
}
