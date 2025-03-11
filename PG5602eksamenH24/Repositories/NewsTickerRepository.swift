//
//  NewsTickerRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 08/12/2024.
//

import Foundation

class NewsTickerRepository {
    private let newsService: NewsService

    init(newsService: NewsService) {
        self.newsService = newsService
    }

    func fetchHeadlines(country: String, category: String, pageSize: Int) async -> [Article]? {
        return await newsService.fetchHeadlines(country: country, category: category, pageSize: pageSize)
    }

    func fetchCategories() async -> [String]? {
        return await newsService.fetchCategories()
    }

    
}
