//
//  CategorySelectionSheet.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 30/11/2024.
//

import SwiftUI

struct CategorySelectionSheet: View {
    @Binding var selectedCategory: Category?
    @Binding var isPresented: Bool
    var categoryRepository: CategoryRepository
    var categories: [Category]
    
    var body: some View {
        NavigationStack {
            List {
                Button("All cateogries") {
                    selectedCategory = nil
                    isPresented = false
                }
                .font(selectedCategory == nil ? .headline : .body)
                
                if categories.isEmpty {
                    Text("No categories available")
                        .font(.body)
                } else {
                    ForEach(categories) { category in
                        Button(category.name) {
                            selectedCategory = category
                            isPresented = false
                        }
                        .font(selectedCategory?.id == category.id ? .headline : .body)
                    }
                }
            }
            .navigationTitle("Select category")
        }
    }
}

//#Preview {
//    //CategorySelectionSheet()
//}
