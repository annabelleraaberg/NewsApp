//
//  NewsService.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import Foundation

struct NewsAPIResponse: Decodable {
    let articles: [Article]
}

struct HeadlineSource: Decodable {
    let id: String
    let name: String
    let category: String
    let country: String
}

struct SourcesResponse: Decodable {
    let sources: [HeadlineSource]
}

class NewsService {
    private let apiKey: String?
    private let headlineBaseURL = "https://newsapi.org/v2/top-headlines"
    private let everythingBaseUrl = "https://newsapi.org/v2/everything"
    
    init() {
        self.apiKey = KeychainService.shared.retreiveAPIKey()
    }
    
    func fetchHeadlines(country: String, category: String, pageSize: Int) async -> [Article]? {
        guard let apiKey = self.apiKey else {
            print("API key not found in Keychain")
            return nil
        }
        guard let url = URL(string: "\(headlineBaseURL)?country=\(country)&category=\(category)&pageSize=\(pageSize)&apiKey=\(apiKey)") else {
            print("Invalid headlines URL")
            return nil
        }
        let urlRequest = URLRequest(url: url)
        
        do {
            // Network request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print(response)
            let articles = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
            print("Fetching headlines for country: \(country), category: \(category), pageSize: \(pageSize)")
            return articles.articles
            
        } catch {
            print("Error fetching headlines: \(error)")
            return nil
        }
    }
    
    func fetchCategories() async -> [String]? {
        guard let apiKey = self.apiKey else {
            print("API key not found in Keychain")
            return nil
        }
        
        guard let url = URL(string: "\(headlineBaseURL)/sources?apiKey=\(apiKey)") else {
            print("Invalid category URL")
            return nil
        }
        let urlRequest = URLRequest(url: url)
        
        do {
            // Network request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print(response)
            let sourcesResponse = try JSONDecoder().decode(SourcesResponse.self, from: data)
            
            // Extract and filter categories from sources
            let categories = Set(sourcesResponse.sources.compactMap { $0.category }.filter { !$0.isEmpty })

            return Array(categories)
        } catch {
            print("Error fetching categories: \(error)")
            return nil
        }
    }
    
    func fetchCountries() async -> [Country]? {
        guard let apiKey = self.apiKey else {
            print("API key not found in Keychain")
            return nil
        }
        
        guard let url = URL(string: "\(headlineBaseURL)/sources?apiKey=\(apiKey)") else {
            print("Invalid country URL")
            return nil
        }
        let urlRequest = URLRequest(url: url)
        
        do {
            // Network request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print("Fetched country sources response: \(response)")
            let sourcesResponse = try JSONDecoder().decode(SourcesResponse.self, from: data)
            
            // Create Country objects and filter duplicates by code
            let countries = sourcesResponse.sources.reduce(into: [String: Country]()) { dict, source in
                guard !source.country.isEmpty else { return }
                dict[source.country] = Country(
                    name: Country.countryName(fromCode: source.country),
                    code: source.country
                )
            }.values
            
            return Array(countries)
        } catch {
            print("Error fetching categories: \(error)")
            return nil
        }
    }
    
    func searchArticles(query: String, searchIn: [String], sortBy: String? = nil, domains: String? = nil, excludeDomains: String? = nil, language: String? = nil, from: String? = nil, to: String? = nil) async -> [Article]? {
        guard let apiKey = self.apiKey else {
            print("API key not found in Keychain")
            return nil
        }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard encodedQuery.count <= 500 else {
            print("Search query is too long")
            return nil
        }
        
        // Join fields with a comma
        let searchInFields = searchIn.joined(separator: ",")
        
        var urlString = "\(everythingBaseUrl)?q=\(encodedQuery)&\(searchInFields)&pageSize=20&apiKey=\(apiKey)"
        print("urlString: \(urlString)")
        
        // Add sortBy if provided
        if let sortBy = sortBy {
            urlString += "&sortBy=\(sortBy)"
        }
        
        if let domains = domains {
            urlString += "&domains=\(domains).com"
        }
        
        if let excludeDomains = excludeDomains {
            urlString += "&excludeDomains=\(excludeDomains).com"
        }
        
        if let language = language {
            urlString += "&language=\(language)"
        }
        if let fromDate = from {
            urlString += "&from=\(fromDate)"
        }
        if let toDate = to {
            urlString += "&to=\(toDate)"
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid search url")
            return nil
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            // Network request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print(response)
            let articles = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
            return articles.articles
        } catch {
            print("Error fetching search results: \(error)")
            return nil
        }
    }
    
    func fetchSources() async -> [Source]? {
        guard let apiKey = self.apiKey else {
            print("API key not found in Keychain")
            return nil
        }
        guard let url = URL(string: "\(headlineBaseURL)/sources?apiKey=\(apiKey)") else {
            print("Invalid sources URL")
            return nil
        }
        let urlRequest = URLRequest(url: url)
        do {
            // Network request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print(response)
            let sourcesResponse = try JSONDecoder().decode(SourcesResponse.self, from: data)
            
            // Convert the fetched sources to Source model
            let sources = sourcesResponse.sources.map { source in
                Source(id: source.id, name: source.name)
            }
            
            return sources
        } catch {
            print("Error fetching sources: \(error)")
            return nil
        }
    }
}

