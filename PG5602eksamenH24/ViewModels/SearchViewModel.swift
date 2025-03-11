//
//  SearchViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 05/12/2024.
//

import Foundation
import SwiftData

@MainActor
class SearchViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var searches: [Search] = []
    @Published var savedKeywords: [String] = []
    @Published var sources: [Source] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var lastSearchQuery: String = ""
    
    private var searchRepository: SearchRepository
    
    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
        loadSavedKeywords()
        fetchSources()
    }
    
    func searchArticles(query: String, searchIn: [String], sortBy: SortSearchOption, language: String? = nil, from: String? = nil, to: String? = nil, domains: [String]? = nil, excludeDomains: [String]? = nil) {
        guard !query.isEmpty else {
            self.errorMessage = "Search query can not be empty"
            return
        }
        isLoading = true
        
        lastSearchQuery = query
        
        let sortOption: String
        switch sortBy {
        case .relevance:
            sortOption = "relevancy"
        case .popularity:
            sortOption = "popularity"
        case .date:
            sortOption = "publishedAt"
        }
        
        let domainsString = (domains?.isEmpty == false) ? domains?.joined(separator: ",") : nil
        let excludeDomainsString = (excludeDomains?.isEmpty == false) ? excludeDomains?.joined(separator: ",") : nil


        Task {
            if let fetchedArticles = await searchRepository.fetchAllArticles(query: query, searchIn: searchIn, sortBy: sortOption, language: language, from: from, to: to, domains: domainsString, excludeDomains: excludeDomainsString) {
                DispatchQueue.main.async {
                    self.articles = fetchedArticles.filter {article in
                        let title = article.title
                        return title != "[Removed]" && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }
                    
                    self.errorMessage = nil
                    self.isLoading = false
                    print("Articles search loaded successfully")
                    print("Sort by: \(sortOption), searchIn: \(searchIn), query: \(query), language: \(language ?? ""), domains: \(domainsString ?? "")")
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Articles search failed to load"
                    self.isLoading = false
                }
            }
        }
    }
    
    enum SortSearchOption {
        case relevance, popularity, date
    }
    
    func loadSavedKeywords(searchText: String? = nil) {
        let fetchedKeywords = searchRepository.fetchSavedKeywords()
        searches = fetchedKeywords
        // Don't show more than 10 keywords at a time
        if let text = searchText, !text.isEmpty {
            savedKeywords = fetchedKeywords
                .map {$0.keyword}
                .filter {$0.lowercased().contains(text.lowercased())}
                .prefix(10)
                .map {$0}
        } else {
            savedKeywords = fetchedKeywords.map { $0.keyword }
        }
        print("Loading keywords: \(savedKeywords)")
    }
    
    func saveSearch(_ search: Search, notes: String? = nil) {
        // Check if the keyword already exists in the savedKeywords list
        if savedKeywords.contains(where: { $0.lowercased() == search.keyword.lowercased() }) {
            print("Duplicate keyword found: \(search.keyword). Not saving.")
            return
        }

        if let notes = notes, !notes.isEmpty {
            search.notes = notes
        }
        
        searchRepository.saveSearch(search)
        print("Saved search with keyword: \(search.keyword) and notes: \(search.notes ?? "")")
        
        loadSavedKeywords()
    }

    func fetchSearchesWithNotes() {
        let searchesWithNotes = searchRepository.fetchSearchesWithNotes()
        self.searches = searchesWithNotes
    }
    
    func fetchSources() {
        isLoading = true
        Task {
            await searchRepository.fetchSources()
            DispatchQueue.main.async {
                self.sources = self.searchRepository.sources
                self.isLoading = false
            }
        }
    }
}
