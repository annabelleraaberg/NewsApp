//
//  SearchRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 05/12/2024.
//

import Foundation
import SwiftData

@MainActor
class SearchRepository {
    @Published var articles: [Article] = []
    @Published var sources: [Source] = []
    
    private var newsService: NewsService
    
    private var context: ModelContext
    
    init(context: ModelContext, newsService: NewsService) {
        self.context = context
        self.newsService = newsService
    }
    
    func fetchAllArticles(query: String, searchIn: [String], sortBy: String, language: String? = nil,from: String? = nil, to: String? = nil, domains: String? = nil, excludeDomains: String? = nil) async -> [Article]? {

        return await newsService.searchArticles(query: query, searchIn: searchIn, sortBy: sortBy, domains: domains, excludeDomains: excludeDomains, language: language, from: from, to: to)
    }
    
    func fetchSavedKeywords() -> [Search] {
        do {
            return try context.fetch(FetchDescriptor<Search>())
            
        } catch {
            print("Failed to fetch saved searches: \(error)")
            return []
        }
    }
    
    func saveSearch(_ search: Search) {
        context.insert(search)
        do {
            try context.save()
            print("Search saved with keyword: \(search.keyword) and notes: \(search.notes ?? "No notes")")
        } catch {
            print("Error saving search: \(error)")
        }
    }
    
    func fetchSearchesWithNotes() -> [Search] {
        do {
            let allSearches = try context.fetch(FetchDescriptor<Search>())
            return allSearches.filter { $0.notes?.isEmpty == false }
        } catch {
            print("Failed to fetch searches with notes: \(error)")
            return []
        }
    }
    
    func fetchSources() async {
        if let fetchedSources = await newsService.fetchSources() {
            print("Fetching sources successful in repository")
            self.sources = fetchedSources
        }
    }
}
