//
//  SaveArticleSheet.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 01/12/2024.
//

import SwiftUI

struct SaveArticleSheet: View {
    @Binding var selectedCategory: Category?
    @Binding var note: String?
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @State private var newCategory = ""
    @State private var categories: [Category] = []
    @State private var isUsingCustomCategory = false
    @State private var isEditingCategory: Bool
    @State private var pickerInteraction = false
    
    @State private var showAlert = false
    
    private var categoryRepository: CategoryRepository
    
    init(selectedCategory: Binding<Category?>, note: Binding<String?>, onSave: @escaping () -> Void, categoryRepository: CategoryRepository, isPresented: Binding<Bool>, isEditingCategory: Bool = false) {
        self._selectedCategory = selectedCategory
        self._note = note
        self.onSave = onSave
        self.categoryRepository = categoryRepository
        self._isPresented = isPresented
        self.isEditingCategory = isEditingCategory
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category")) {
                    Picker("Category Mode", selection: $isUsingCustomCategory) {
                        Text("Choose Existing").tag(false)
                        Text("Create New").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if isUsingCustomCategory {
                        TextField("New category", text: $newCategory)
                            .textFieldStyle(.roundedBorder)
                            .padding(.vertical)
                    } else {
                        Picker("Select Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.id) { category in
                                Text(category.name).tag(category as Category?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedCategory) { noCategory, category in
                            pickerInteraction = true
                        }
                    }
                }
                
                if !isEditingCategory {
                    Section(header: Text("Note")) {
                        TextField("Notes", text: Binding(
                            get: { note ?? "" },
                            set: { note = $0.isEmpty ? nil : $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .navigationBarTitle("Save Article", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                validateAndSave()
                
            })
            .onAppear {
                self.categories = categoryRepository.getAllCategories()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Category Required"),
                    message: Text("Please select a category before saving"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    private func validateAndSave() {
        if isUsingCustomCategory {
            if newCategory.isEmpty {
                showAlert = true
                return
            }
            let newCategoryObject = categoryRepository.addCategory(withName: newCategory)
            selectedCategory = newCategoryObject
        }
        
        // Check if a valid category has been selected in the picker
        if !isUsingCustomCategory && (!pickerInteraction || selectedCategory == nil || selectedCategory?.id == nil) {
            showAlert = true
            return
        }
        
        onSave()
        isPresented = false
    }
}


