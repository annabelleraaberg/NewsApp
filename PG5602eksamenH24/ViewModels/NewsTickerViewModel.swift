//
//  NewsTickerViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 04/12/2024.
//

import SwiftUI

class NewsTickerViewModel: ObservableObject {
    @Published var selectedTickerCountry: String = "us"
    @Published var selectedTickerCategory: String = "technology"
    @Published var pageSize: Int = 10
    @Published var articles: [Article] = []
    @Published var categories: [String] = []
    @Published var countries: [Country] = []
    @Published var noArticlesFound: Bool = false
    
    private var newsTickerRepository: NewsTickerRepository
    private var settingsRepository: SettingsRepository
    private var countryRepository: CountryRepository
    
    init(newsTickerRepository: NewsTickerRepository, settingsRepository: SettingsRepository = SettingsRepository.shared, countryRepository: CountryRepository) {
        self.newsTickerRepository = newsTickerRepository
        self.settingsRepository = settingsRepository
        self.countryRepository = countryRepository
        
        self.selectedTickerCategory = settingsRepository.loadSelectedTickerCategory()
        self.selectedTickerCountry = settingsRepository.loadSelectedTickerCountry()
        self.pageSize = settingsRepository.loadPageSize()
        
        Task {
            await loadCountries()
        }
        Task {
            await loadCategories()
        }
    }
    
    func loadHeadlines() async {
        var fetchedArticles: [Article] = []

        while fetchedArticles.count < pageSize {
            if let additionalArticles = await newsTickerRepository.fetchHeadlines(
                country: selectedTickerCountry,
                category: selectedTickerCategory,
                pageSize: pageSize - fetchedArticles.count
            ) {
                let validArticles = additionalArticles.filter { article in
                    let title = article.title
                    return title != "[Removed]" && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                fetchedArticles.append(contentsOf: validArticles)

                // Break the loop if there are no more articles to fetch
                if additionalArticles.isEmpty || validArticles.isEmpty {
                    break
                }
            } else {
                break
            }
        }

        DispatchQueue.main.async { [articles = fetchedArticles] in
            self.articles = articles
            self.noArticlesFound = self.articles.isEmpty
        }

    }
    
    func updateHeadlines() async {
        print("news ticker view model - headlines for category: \(selectedTickerCategory), pageSize: \(pageSize)")
        await loadHeadlines()
    }
    
    func loadCategories() async {
        if let fetchedCategories = await newsTickerRepository.fetchCategories() {
            DispatchQueue.main.async {
                self.categories = fetchedCategories
            }
        }
    }
    
    func changeCategory(to category: String) {
        selectedTickerCategory = category
        settingsRepository.saveSelectedTickerCategory(category)
        print("Changed news ticker category to: \(category)")
        Task {
            await updateHeadlines()
        }
    }
    
    func changePageSize(to pageSize: Int) {
        self.pageSize = pageSize
        settingsRepository.savePageSize(pageSize)
        print("news ticker view model - news ticker size changed: \(pageSize)")
        Task {
            await updateHeadlines()
        }
    }
    
    func loadCountries() async {
        do {
            let localCountries = try await countryRepository.loadAllCountries()
            
            if localCountries.isEmpty {
                // If no countries are in the local database, fetch from API
                print("No countries in local DB, fetching from API...")
                if let fetchedCountries = await countryRepository.fetchCountries() {
                    // Store fetched countries in the local database
                    await countryRepository.saveCountries(fetchedCountries)
                    
                    DispatchQueue.main.async {
                        self.countries = fetchedCountries
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.countries = localCountries
                }
            }
        } catch {
            print("Error loading countries: \(error)")
        }
    }
    
    func changeCountry(to country: String) {
        selectedTickerCountry = country
        settingsRepository.saveSelectedTickerCountry(country)
        print("Changed news ticker country to: \(country)")
        
        Task {
            await updateHeadlines()
            
            // Check if articles are empty after fetching
            if self.articles.isEmpty {
                DispatchQueue.main.async {
                    self.noArticlesFound = true
                    print("No articles found for country: \(self.selectedTickerCountry)")
                }
            } else {
                DispatchQueue.main.async {
                    self.noArticlesFound = false
                }
            }
        }
    }
}


