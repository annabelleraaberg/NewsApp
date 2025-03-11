//
//  SplashView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var rotationAngle: Double = 0.0
    @Environment(\.modelContext) private var modelContext  
    
    var settingsViewModel: SettingsViewModel
    var viewModel: ArticlesViewModel
    var newsTickerViewModel: NewsTickerViewModel
    var selectedArticle: Binding<Article?>
    var categoryRepository: CategoryRepository
    var countryRepository: CountryRepository
    var articleRepository: ArticleRepository
    var newsService: NewsService
    
    init(
        settingsViewModel: SettingsViewModel,
        viewModel: ArticlesViewModel,
        newsTickerViewModel: NewsTickerViewModel,
        selectedArticle: Binding<Article?>,
        categoryRepository: CategoryRepository,
        countryRepository: CountryRepository,
        articleRepository: ArticleRepository,
        newsService: NewsService
    ) {
        self.settingsViewModel = settingsViewModel
        self.viewModel = viewModel
        self.newsTickerViewModel = newsTickerViewModel
        self.selectedArticle = selectedArticle
        self.categoryRepository = categoryRepository
        self.countryRepository = countryRepository
        self.articleRepository = articleRepository
        self.newsService = newsService
    }
    
    var body: some View {
        if isActive {
            ContentView(
                viewModel: viewModel,
                categoryViewModel: CategoryViewModel(repository: categoryRepository, articleRepository: articleRepository),
                articleRepository: articleRepository,
                categoryRepository: categoryRepository,
                newsTickerViewModel: newsTickerViewModel,
                countryRepository: countryRepository,
                searchRepository: SearchRepository(context: modelContext, newsService: newsService), 
                searchViewModel: SearchViewModel(searchRepository: SearchRepository(context: modelContext, newsService: newsService)),
                notesViewModel: NotesViewModel(countryRepository: countryRepository)
            )
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    Image("newsGlobe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scaleEffect)
                        .onAppear {
                            withAnimation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                            ) {
                                scaleEffect = 1.2
                            }
                            withAnimation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                            ) {
                                rotationAngle = 360
                            }
                        }
                    Text("Global News App")
                        .font(.largeTitle)
                        .foregroundStyle(Color("CustomTextColor"))
                        .padding()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = true
                }
            }
        }
    }
}

//#Preview {
//    SplashView()
//}
