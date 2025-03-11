//
//  SettingsView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = ""
    @State private var apiKeySavedMessage: String? = nil
    @StateObject var apiKeyViewModel = APIKeyViewModel()
    
    @State private var selectedCategory: Category? = nil
    @State private var newCategoryName: String = ""
    @State private var editingCategoryName: String = ""
    @State private var isEditingCategory: Bool = false
    @State private var categoryNote: String = ""
    
    @State private var showAlert = false
    @State private var successMessage: String? = nil
    @State private var showDeleteConfirmationButtons: Bool = false
    @State private var confirmationAction: (() -> Void)?
    
    @Binding var headlineFontSize: CGFloat
    @Binding var headlineFontColor: Color
    
    @StateObject var viewModel: ArticlesViewModel
    @StateObject var categoryViewModel: CategoryViewModel
    @StateObject var settingsViewModel: SettingsViewModel
    @StateObject var newsTickerViewModel: NewsTickerViewModel
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var notesViewModel: NotesViewModel
    
    var categoryRepository: CategoryRepository
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Toggle(isOn: $settingsViewModel.isDarkMode) {
                        Text("Dark Mode")
                            .font(.headline)
                    }
                    .padding()
                    
                    generalSettingsSection
                    categoryManagementSection
                    newsTickerSection
                    newsTickerSizeModifierSection
                    newsTickerColorModifierSection
                }
                .padding()
                .cornerRadius(10)
                .onAppear {
                    viewModel.loadSavedArticles()
                    categoryViewModel.loadCategories()
                    if let storedKey = apiKeyViewModel.loadAPIKey() {
                        apiKey = storedKey
                    }
                }
                
                VStack {
                    NavigationLink(destination: ArchivedArticlesView(viewModel: viewModel, settingsViewModel: settingsViewModel, categoryRepository: categoryRepository)) {
                        Text("Archived Articles")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical)
                            .padding(.horizontal, 20)
                            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                            .padding(.bottom, 10)
                    }
                    NavigationLink(destination: NotesView(searchViewModel: searchViewModel, notesViewModel: notesViewModel, categoryViewModel: categoryViewModel)) {
                        Text("Saved Notes")
                            .font(.body)
                            .foregroundColor(.primary) 
                            .padding(.vertical)
                            .padding(.horizontal, 20)
                            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showAlert) {
                if showDeleteConfirmationButtons {
                    // Alert 2: Confirm Deletion
                    return Alert(
                        title: Text("Confirm Deletion"),
                        message: Text(successMessage ?? "This category is safe to delete."),
                        primaryButton: .destructive(Text("Delete")) {
                            confirmationAction?()
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    // Alert 1 or 3: Cannot delete or Successfully deleted
                    return Alert(
                        title: Text("Category Deletion"),
                        message: Text(successMessage ?? ""),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .onDisappear {
                settingsViewModel.saveAllPreferences()
            }
        }
    }
    
    // MARK: – Sections
    private var generalSettingsSection: some View {
        Section(header: Text("General Settings").font(.headline)) {
            VStack(alignment: .leading) {
                Text("API key")
                
                if let message = apiKeySavedMessage {
                    Text(message)
                        .foregroundStyle(.green)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                }
                
                TextField("Enter your API key", text: $apiKey)
                    .padding()
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Button("Save API Key") {
                    apiKeyViewModel.saveAPIKey(apiKey)
                    apiKeySavedMessage = "API key saved!"
                }
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(8)
                
                Button("Clear API Key") {
                    apiKeyViewModel.clearAPIKey()
                    apiKey = ""
                    apiKeySavedMessage = "API Key cleared!"
                }
                .padding()
                .cornerRadius(8)
            }
        }
    }
    
    private var categoryManagementSection: some View {
        Section(header: Text("Category Management").font(.headline)) {
            VStack {
                Text("Select a category to edit")
                    .font(.title3)
                Text("When you select a category, you can choose to either edit its name or delete it")
                    .font(.body)
                Picker("Select Category", selection: $selectedCategory) {
                    Text("None").tag(nil as Category?)
                    ForEach(categoryViewModel.categories, id: \.id) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                
                if let selectedCategory = selectedCategory {
                    VStack {
                        
                        Text("Edit Category Name:")
                        if let successMessage = successMessage {
                            Text(successMessage)
                                .foregroundStyle(.black)
                                .padding()
                        }
                        
                        TextField("Edit category name", text: $editingCategoryName)
                            .textFieldStyle(.roundedBorder)
                            .onAppear {
                                editingCategoryName = selectedCategory.name
                            }
                        
                        HStack {
                            Button(action: {
                                let trimmedCategoryName = editingCategoryName.trimmingCharacters(in: .whitespaces)
                                if !trimmedCategoryName.isEmpty {
                                    viewModel.updateCategoryName(selectedCategory, newName: trimmedCategoryName)
                                    editingCategoryName = ""
                                    successMessage = "Category name updated successfully"
                                } else {
                                    print("Category name cannot be empty")
                                }
                            }) {
                                Text("Update Category")
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(editingCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                            
                            Button(action: {
                                showDeleteConfirmation(for: selectedCategory)
                            }) {
                                Text("Delete Category")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                                
                            }
                            .padding(.leading)
                        }
                    }
                } else {
                    Text("Please select a category to edit")
                        .padding()
                }
                
                Text("Add a new category")
                TextField("Enter new category name", text: $newCategoryName)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter note for category", text: $categoryNote)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Add Category") {
                        let trimmedCategoryName = newCategoryName.trimmingCharacters(in: .whitespaces)
                        let trimmedCategoryNote = categoryNote.trimmingCharacters(in: .whitespaces)
                        
                        if !trimmedCategoryName.isEmpty {
                            categoryViewModel.addCategory(name: trimmedCategoryName, note: trimmedCategoryNote)
                            newCategoryName = ""
                            categoryNote = ""
                            
                        } else {
                            print("Category name cannot be empty")
                        }
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    private var newsTickerSection: some View {
        Section(header: Text("Ticker Settings").font(.headline)) {
            VStack(alignment: .leading) {
                Picker("Ticker position", selection: $settingsViewModel.tickerPosition) {
                    Text("Top").tag("Top")
                    Text("Bottom").tag("Bottom")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("Show news ticker", isOn: $settingsViewModel.showTicker)
                
                Stepper("Number of articles: \(settingsViewModel.pageSize)", value: $settingsViewModel.pageSize, in: 1...20)
                    .onChange(of: settingsViewModel.pageSize) { oldSize, newSize in
                        newsTickerViewModel.changePageSize(to: newSize)
                    }
                
                Picker("News Ticker Category", selection: $settingsViewModel.selectedTickerCategory) {
                    ForEach(newsTickerViewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: settingsViewModel.selectedTickerCategory) { oldValue, newValue in
                    newsTickerViewModel.changeCategory(to: newValue)
                }
                
                Picker("News Ticker Country", selection: $settingsViewModel.selectedTickerCountry) {
                    
                    // Note: Simulate choosing all countries even though only us is available
                    Text("All countries").tag("us")
                    ForEach(newsTickerViewModel.countries, id: \.code) { country in
                        Text(country.name).tag(country.code)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: settingsViewModel.selectedTickerCountry) { oldValue, newValue in
                    newsTickerViewModel.changeCountry(to: newValue)
                }
                Text("Note: The only available country right now is United States.")
                    .font(.footnote)
            }
            .padding()
            .cornerRadius(10)
        }
    }
    
    func showDeleteConfirmation(for category: Category) {
        Task {
            // Check if there are articles connected to this category
            if categoryViewModel.doesCategoryHaveArticles(category) {
                successMessage = "You cannot delete this category because it has articles associated to it."
                showDeleteConfirmationButtons = false
                showAlert = true
            } else {
                // If there are no articles, confirm delete
                successMessage = "This category is safe to delete. No articles associated."
                showDeleteConfirmationButtons = true
                showAlert = true
                
                confirmationAction = {
                    Task {
                        do {
                            let success = try await categoryViewModel.deleteCategory(category)
                            if success {
                                successMessage = "Category deleted successfully."
                                editingCategoryName = ""
                            } else {
                                successMessage = "Failed to delete category."
                            }
                            showDeleteConfirmationButtons = false
                            showAlert = true
                        } catch {
                            successMessage = "Error deleting category"
                            showDeleteConfirmationButtons = false
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
    
    private var newsTickerSizeModifierSection: some View {
        Section(header: Text("News Ticker Font Size").font(.headline)) {
            Text("Font size: \(String(format: "%.0f", settingsViewModel.headlineFontSize))")
            Slider(value: $headlineFontSize, in: 12...30, step: 1) {
                Text("Font Size")
            }
            .onChange(of: headlineFontSize) { oldSize, newSize in
                settingsViewModel.headlineFontSize = newSize
            }
            .padding()
        }
    }
    
    private var newsTickerColorModifierSection: some View {
        Section(header: Text("News Ticker Font Color").font(.headline)) {
            HStack {
                Text("Font color: ")
                Rectangle()
                    .fill(headlineFontColor)
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
            }
            ColorPicker("Font Color", selection: $headlineFontColor)
                .padding()
                .onChange(of: headlineFontColor) { oldColor, newColor in
                    settingsViewModel.headlineFontColor = newColor
                }
        }
    }
}

//#Preview {
//    //SettingsView()
//}
