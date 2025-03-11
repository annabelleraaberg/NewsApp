//
//  PG5602eksamenH24App.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI
import SwiftData

@main
struct PG5602eksamenH24App: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Country.self,
            Category.self,
            Search.self,
            Article.self
        ])
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = documentsDirectory.appendingPathComponent("newsapi.store")
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            let articleRepository = ArticleRepository(context: sharedModelContainer.mainContext)
            let categoryRepository = CategoryRepository(
                context: sharedModelContainer.mainContext,
                articleRepository: articleRepository
            )
            let countryRepository = CountryRepository(context: sharedModelContainer.mainContext, newsService: NewsService())
            
            // Pass shared state through .environmentObject
            SplashView(
                settingsViewModel: settingsViewModel,
                viewModel: ArticlesViewModel(
                    articleRepository: articleRepository,
                    categoryRepository: categoryRepository
                ),
                newsTickerViewModel: NewsTickerViewModel(
                    newsTickerRepository: NewsTickerRepository(newsService: NewsService()), countryRepository: countryRepository
                ),
                selectedArticle: .constant(nil),
                categoryRepository: categoryRepository,
                countryRepository: countryRepository, articleRepository: ArticleRepository(context: sharedModelContainer.mainContext), newsService: NewsService()
            )
            .environment(\.modelContext, sharedModelContainer.mainContext)
            .toggleColorScheme(isDarkMode: $settingsViewModel.isDarkMode)
            .environmentObject(settingsViewModel)
        }
    }
}
