//
//  CategoryRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 30/11/2024.
//

import Foundation
import SwiftData

class CategoryRepository {
    private var context: ModelContext
    private var articleRepository: ArticleRepository
    
    init(context: ModelContext, articleRepository: ArticleRepository) {
        self.context = context
        self.articleRepository = articleRepository
    }
    
    func getAllCategories() -> [Category] {
        let descriptor = FetchDescriptor<Category>()
        do {
            let categories = try context.fetch(descriptor)
            return categories
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func saveCategory(_ category: Category, article: Article? = nil) {
        if let article = article {
            category.articles.append(article)
        }
        do {
            context.insert(category)
            try context.save()
            print("Category saved successfully: \(category.name)")
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    func addCategory(withName name: String, note: String? = nil) -> Category {
        // Check if a category with the same name already exists
        let existingCategories = getAllCategories()
        if let existingCategory = existingCategories.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            // If the category exists, return the existing category
            print("Category '\(name)' already exists. Article will be saved to this category.")
            return existingCategory
        }
        
        // If the category does not exist, create a new category
        let newCategory = Category(name: name, notes: note)
        print("Adding new category: \(newCategory.name) and note: \(newCategory.notes ?? "no note")")
        
        saveCategory(newCategory)
        
        return newCategory
    }
    
    // Updates the name of a category and articles associated with that category
    @MainActor func updateCategoryName(_ category: Category, newName: String) {
        let trimmedNewName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedNewName.isEmpty else {
            print("Category name cannot be empty")
            return
        }
        
        category.name = trimmedNewName
        
        // Update associated articles
        for article in category.articles {
            do {
                try articleRepository.updateArticle(article, category: category)
                print("Updated category and associated articles successfully")
            } catch {
                print("Failed to update article with new category: \(error)")
            }
        }
        
        do {
            try context.save()
            print("Category updated successfully: \(category.name)")
        } catch {
            print("Error updating category: \(error)")
        }
    }
    
    func deleteCategory(_ category: Category) {
        context.delete(category)
        do {
            try context.save()
            print("Category deleted successfully: \(category.name)")
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    func getCategoriesWithNotes() -> [Category] {
        do {
            let allCategories = try context.fetch(FetchDescriptor<Category>())
            
            // Filter categories with non-empty notes
            let categoriesWithNotes = allCategories.filter { category in
                guard let notes = category.notes else { return false }
                return !notes.isEmpty
            }
            
            return categoriesWithNotes
        } catch {
            print("Error fetching categories with notes: \(error)")
            return []
        }
    }
}
