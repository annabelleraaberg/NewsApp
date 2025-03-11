//
//  CategoryViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 02/12/2024.
//

import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var categoriesWithNotes: [Category] = []
    @Published var isLoading: Bool = false
    @Published var isEditingCategory: Bool = false
    @Published var categoryToEdit: Category? = nil
    @Published var newCategoryName: String = ""
    
    private var repository: CategoryRepository
    private var articleRepository: ArticleRepository
    
    init(repository: CategoryRepository, articleRepository: ArticleRepository) {
        self.repository = repository
        self.articleRepository = articleRepository
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        
        let categories = self.repository.getAllCategories()
        
        self.categories = categories
        self.isLoading = false
    }
    
    func addCategory(name: String, note: String) {
        let newCategory = repository.addCategory(withName: name, note: note)
        categories.append(newCategory)
    }
    
    func resetEditingState() {
        isEditingCategory = false
        categoryToEdit = nil
        newCategoryName = ""
    }
    
    // Note: Assuming deleting category means just the category and not articles associated with the category since cascade deleting should not be used according to the exam paper.
    func deleteCategory(_ category: Category) async throws -> Bool {
        if !doesCategoryHaveArticles(category) {
            // No articles, safe to delete
            repository.deleteCategory(category)
            
            DispatchQueue.main.async {
                if let index = self.categories.firstIndex(where: { $0.id == category.id }) {
                    self.categories.remove(at: index)
                }
            }
            
            // Successful deletion
            return true
        } else {
            // Category has articles, deletion is not allowed
            return false
        }
    }
    
    func doesCategoryHaveArticles(_ category: Category) -> Bool {
        return category.articles.count > 0
    }
    
    func canDeleteCategory(_ category: Category) -> Bool {
        return !doesCategoryHaveArticles(category)
    }
    
    func fetchCategoriesWithNotes() {
        categoriesWithNotes = repository.getCategoriesWithNotes()
    }
}


