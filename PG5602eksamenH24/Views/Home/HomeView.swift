//  ArticleView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @StateObject var viewModel: ArticlesViewModel
    @StateObject var newsTickerViewModel: NewsTickerViewModel
    @Binding var selectedArticle: Article?
    
    @State private var selectedCategory: Category? = nil
    @State private var isTopMenuPresented = false
    @State private var enlargedArticle: Article? = nil
    @State private var headlineToDisplay: String?
    
    var categoryRepository: CategoryRepository
    var countryRepository: CountryRepository
    
    var filteredArticles: [Article] {
        guard let category = selectedCategory else {
            return viewModel.savedArticles
        }
        return viewModel.savedArticles.filter { $0.category.id == category.id }
    }
    
    var categoriesWithArticles: [Category] {
        let allCategories = categoryRepository.getAllCategories()
        return allCategories.filter { category in
            let articlesInCategory = viewModel.savedArticles.filter { $0.category.id == category.id }
            return !articlesInCategory.isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                headlineView
                
                VStack {
                    if settingsViewModel.showTicker && settingsViewModel.tickerPosition == "Top" {
                        tickerView
                            .frame(height: 50)
                            .padding(.top, 10)
                    }
                    
                    if filteredArticles.isEmpty {
                        emptyArticlesView
                    } else {
                        articleListView
                    }
                    
                    if settingsViewModel.showTicker && settingsViewModel.tickerPosition == "Bottom" {
                        tickerView
                            .frame(height: 50)
                            .padding(.bottom, 10)
                    }
                }
                .onAppear {
                    Task {
                        await newsTickerViewModel.loadHeadlines()
                        viewModel.loadSavedArticles()
                        print("Homeview appeared, loading headlines: \(newsTickerViewModel.articles.count)")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isTopMenuPresented = true
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                }
                .sheet(isPresented: $isTopMenuPresented) {
                    CategorySelectionSheet(
                        selectedCategory: $selectedCategory,
                        isPresented: $isTopMenuPresented,
                        categoryRepository: categoryRepository,
                        categories: categoriesWithArticles
                    )
                    .toggleColorScheme(isDarkMode: $settingsViewModel.isDarkMode)
                }
            }
        }
    }
    
    // MARK: – Subviews 
    private var headlineView: some View {
        Group {
            if let headline = headlineToDisplay {
                Text(headline)
                    .font(.largeTitle)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            headlineToDisplay = nil
                        }
                    }
                    .zIndex(1)
            }
        }
    }
    
    private var tickerView: some View {
        NewsTickerView(
            newsTickerViewModel: newsTickerViewModel,
            tickerPosition: $settingsViewModel.tickerPosition,
            showTicker: $settingsViewModel.showTicker,
            selectedTickerCountry: $settingsViewModel.selectedTickerCountry,
            selectedTickerCategory: $settingsViewModel.selectedTickerCategory,
            pageSize: $settingsViewModel.pageSize,
            headlineToDisplay: $headlineToDisplay,
            fontSize: $settingsViewModel.headlineFontSize,
            fontColor: $settingsViewModel.headlineFontColor
        )
    }
    
    private var emptyArticlesView: some View {
        VStack {
            Spacer()
            Image("newsIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.gray)
                .padding(.bottom, 16)
            
            Text("No articles are saved")
                .font(.headline)
            Text("Please go to search and fetch articles and news from the internet")
                .font(.footnote)
                .foregroundStyle(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var articleListView: some View {
        List {
            ForEach(filteredArticles, id: \.self) { article in
                NavigationLink(destination: ArticleDetailsView(article: article, viewModel: viewModel, settingsViewModel: settingsViewModel, categoryRepository: categoryRepository)) {
                    HStack {
                        if let imageUrl = article.imageUrl {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(8)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.headline)
                                .lineLimit(2)
                            if let author = article.author {
                                Text(author)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.archiveArticle(article)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                }
            }
        }
    }
}
