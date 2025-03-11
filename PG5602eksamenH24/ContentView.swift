//
//  ContentView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var showTicker: Bool = true
    @State private var tickerPosition: String = "Top"
    @State private var selectedArticle: Article?
    @State private var headlineFontSize: CGFloat = 16
    @State private var headlineFontColor: Color = Color.black
    
    private var viewModel: ArticlesViewModel
    private var categoryViewModel: CategoryViewModel
    private var articleRepository: ArticleRepository
    private var categoryRepository: CategoryRepository
    private var countryRepository: CountryRepository
    private var newsTickerViewModel: NewsTickerViewModel
    private var searchRepository: SearchRepository
    private var searchViewModel: SearchViewModel
    private var notesViewModel: NotesViewModel
    
    init(viewModel: ArticlesViewModel, categoryViewModel: CategoryViewModel, articleRepository: ArticleRepository, categoryRepository: CategoryRepository, newsTickerViewModel: NewsTickerViewModel, countryRepository: CountryRepository, searchRepository: SearchRepository, searchViewModel: SearchViewModel, notesViewModel: NotesViewModel) {
        self.viewModel = viewModel
        self.categoryViewModel = categoryViewModel
        self.articleRepository = articleRepository
        self.categoryRepository = categoryRepository
        self.countryRepository = countryRepository
        self.newsTickerViewModel = newsTickerViewModel
        self.searchRepository = searchRepository
        self.searchViewModel = searchViewModel
        self.notesViewModel = notesViewModel
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                HomeView(
                    settingsViewModel: settingsViewModel,
                    viewModel: viewModel,
                    newsTickerViewModel: newsTickerViewModel,
                    selectedArticle: $selectedArticle,
                    categoryRepository: categoryRepository,
                    countryRepository: countryRepository
                )
                .tabItem {
                    Label("Articles", systemImage: "doc.plaintext.fill")
                }
                SearchView(
                    viewModel: viewModel,
                    settingsViewModel: settingsViewModel,
                    searchRepository: searchRepository,
                    categoryRepository: categoryRepository)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                SettingsView(
                    headlineFontSize: $headlineFontSize,
                    headlineFontColor: $headlineFontColor,
                    viewModel: viewModel,
                    categoryViewModel: categoryViewModel,
                    settingsViewModel: settingsViewModel,
                    newsTickerViewModel: newsTickerViewModel,
                    searchViewModel: searchViewModel,
                    notesViewModel: notesViewModel,
                    categoryRepository: categoryRepository
                )
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}


//#Preview {
//    //    ContentView()
//    //        .modelContainer(for: Item.self, inMemory: true)
//}
