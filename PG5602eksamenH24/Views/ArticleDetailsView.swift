//
//  ArticleDetailsView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI

struct ArticleDetailsView: View {
    let article: Article
    @ObservedObject var viewModel: ArticlesViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State private var isSaveSheetPresented = false
    @State private var selectedCategory: Category?
    
    @State private var note: String? = ""
    @State private var isNotesVisible: Bool = false
    @State private var isEditingNote: Bool = false
    
    var categoryRepository: CategoryRepository
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                articleImageSection
                saveStatusSection
                articleInfoSection
                articleContentSection
                noteSection
            }
            .padding()
        }
        .onAppear {
            selectedCategory = article.category
            note = article.notes ?? ""
        }
        .navigationTitle("Article Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    private var articleImageSection: some View {
        Group {
            if let imageUrl = article.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
    
    private var saveStatusSection: some View {
        Group {
            if viewModel.isArticleSaved(article) {
                Text("Saved")
                    .foregroundStyle(.green)
                
                Text("Saved at: \(viewModel.formattedCreatedAt(for: article))")
                    .font(.footnote)
                Text("Last updated: \(viewModel.formattedUpdatedAt(for: article))")
                    .font(.footnote)
                
                Text("Category: \(article.category.name)")
                    .padding(.trailing, 8)
                
                Button(action: {
                    isSaveSheetPresented.toggle()
                }) {
                    Text("Edit Category")
                        .foregroundStyle(.blue)
                        .underline()
                }
                .sheet(isPresented: $isSaveSheetPresented) {
                    SaveArticleSheet(
                        selectedCategory: Binding(
                            get: { selectedCategory },
                            set: { newCategory in
                                selectedCategory = newCategory
                            }),
                        note: $note,
                        onSave: {
                            if let selectedCategory = selectedCategory {
                                article.category = selectedCategory
                                viewModel.updateCategoryForArticle(article)
                            }
                            viewModel.loadSavedArticles()
                        },
                        categoryRepository: categoryRepository, isPresented: $isSaveSheetPresented
                    )
                    .toggleColorScheme(isDarkMode: $settingsViewModel.isDarkMode)
                }
                .onAppear {
                    selectedCategory = article.category
                }
            } else if !viewModel.isArticleArchived(article) {
                saveArticleButton
            }
        }
    }
    
    private var saveArticleButton: some View {
        Button(action: {
            if selectedCategory == nil {
                print("Category must be selected before saving")
            } else {
                isSaveSheetPresented.toggle()
            }
        }) {
            Text("Save Article")
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(8)
        }
        .sheet(isPresented: $isSaveSheetPresented) {
            SaveArticleSheet(
                selectedCategory: $selectedCategory,
                note: $note,
                onSave: {
                    if let selectedCategory {
                        viewModel.saveArticle(article, category: selectedCategory, note: note)
                        article.category = selectedCategory
                        viewModel.updateCategoryForArticle(article)
                    }
                },
                categoryRepository: categoryRepository, isPresented: $isSaveSheetPresented
            )
            .toggleColorScheme(isDarkMode: $settingsViewModel.isDarkMode)
        }
    }
    
    private var articleInfoSection: some View {
        Group {
            Text(article.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text(viewModel.formattedPublishedAt(for: article))
                .font(.footnote)
            
            if let author = article.author {
                Text("Author: \(author)")
                    .font(.footnote)
            }
            
            Text("Source: \(article.source.name)")
                .font(.footnote)
        }
    }
    
    private var articleContentSection: some View {
        Group {
            if let description = article.articleDescription {
                Text(description)
                    .font(.body)
                    .padding(.bottom, 8)
            }
            
            if let content = article.content {
                Text(content)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var noteSection: some View {
        Group {
            if viewModel.isArticleSaved(article) {
                if let savedNotes = article.notes, !savedNotes.isEmpty {
                    Text("Notes")
                    Text(savedNotes)
                        .padding(.bottom, 8)
                    
                    Button(action: {
                        isEditingNote.toggle()
                        note = savedNotes
                    }) {
                        Text("Edit Note")
                            .foregroundStyle(.blue)
                            .underline()
                    }
                } else {
                    Button(action: {
                        isEditingNote.toggle()
                    }) {
                        Text("Add Note")
                            .foregroundStyle(.blue)
                            .underline()
                    }
                }
                
                if isEditingNote {
                    TextEditor(text: Binding(
                        get: {note ?? ""},
                        set: {note = $0}
                    ))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.bottom, 8)
                    
                    Button(action: {
                        article.notes = note ?? ""
                        if let selectedCategory = selectedCategory {
                            viewModel.saveArticle(article, category: selectedCategory, note: note)
                        }
                        isEditingNote = false
                    }) {
                        Text("Save Note")
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}



//#Preview {
//    //ArticleDetailsView()
//}
