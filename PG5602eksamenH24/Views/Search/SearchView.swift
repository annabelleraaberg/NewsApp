//
//  SearchView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject private var viewModel: ArticlesViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @State private var query = ""
    @State private var lastQuery = ""
    @State private var searchIn: [String] = ["title"]
    @State private var sortSearchOption: SearchViewModel.SortSearchOption = .relevance
    @State private var showingSearchSheet = false
    @State private var domains: [String] = []
    @State private var excludeDomains: [String] = []
    @State private var language: String = "en"
    @State private var fromDate = Date()
    @State private var toDate = Date()
    
    @State private var note: String? = ""
    
    private var categoryRepository: CategoryRepository
    private var searchRepository: SearchRepository
    
    init(viewModel: ArticlesViewModel, settingsViewModel: SettingsViewModel, searchRepository: SearchRepository, categoryRepository: CategoryRepository) {
        self.viewModel = viewModel
        self.settingsViewModel = settingsViewModel
        self.searchRepository = searchRepository
        self.categoryRepository = categoryRepository
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(searchRepository: searchRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button(action: {
                        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedQuery.isEmpty {
                            if trimmedQuery != searchViewModel.lastSearchQuery {
                                searchViewModel.saveSearch(Search(keyword: trimmedQuery, notes: note))
                                print("query: \(trimmedQuery)")
                            }
                            searchViewModel.searchArticles(query: trimmedQuery, searchIn: searchIn, sortBy: sortSearchOption, language: language)
                            query = trimmedQuery
                        } else {
                            print("Search query cannot be empty")
                        }
                    }) {
                        Text("Search")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 16)
                }
                
                Button("Advanced Search") {
                    showingSearchSheet.toggle()
                }
                .sheet(isPresented: $showingSearchSheet) {
                    SearchCriteriaSheet(
                        query: $query,
                        searchIn: $searchIn,
                        sortSearchOption: $sortSearchOption,
                        domains: $domains,
                        excludeDomains: $excludeDomains,
                        isPresented: $showingSearchSheet,
                        note: $note,
                        selectedLanguage: $language,
                        fromDate: $fromDate,
                        toDate: $toDate,
                        onSearch: {
                            searchViewModel.searchArticles(query: query, searchIn: searchIn, sortBy: sortSearchOption, language: language, from: ISO8601DateFormatter().string(from: fromDate), to: ISO8601DateFormatter().string(from: toDate), domains: domains, excludeDomains: excludeDomains)
                        },
                        searchViewModel: searchViewModel
                    )
                    .toggleColorScheme(isDarkMode: $settingsViewModel.isDarkMode)
                }
                
                Spacer()
                
                if searchViewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if searchViewModel.articles.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List(searchViewModel.articles, id: \.id) { article in
                        NavigationLink(destination: ArticleDetailsView(article: article, viewModel: viewModel, settingsViewModel: settingsViewModel, categoryRepository: categoryRepository)) {
                            Text(article.title)
                        }
                    }
                }
            }
            .onAppear {
                lastQuery = searchViewModel.lastSearchQuery
            }
        }
    }
}

//#Preview {
//    //SearchView()
//}
