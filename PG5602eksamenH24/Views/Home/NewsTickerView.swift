//
//  NewsTickerView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 22/11/2024.
//

import SwiftUI

import SwiftUI

struct NewsTickerView: View {
    @StateObject var newsTickerViewModel: NewsTickerViewModel

    @Binding var tickerPosition: String
    @Binding var showTicker: Bool
    @Binding var selectedTickerCountry: String
    @Binding var selectedTickerCategory: String
    @Binding var pageSize: Int
    @Binding var headlineToDisplay: String?
    @Binding var fontSize: CGFloat
    @Binding var fontColor: Color

    @State private var offset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var isAnimating = false
    @State private var totalArticlesProcessed = 0
    
    private let baseAnimationDuration: Double = 10.0
    private let speed: CGFloat = 80

    var body: some View {
        GeometryReader { geometry in
            let tickerWidth = geometry.size.width
            
            VStack {
                if tickerPosition == "top" {
                    Spacer(minLength: 0)
                }

                if newsTickerViewModel.noArticlesFound {
                    noArticlesView()
                } else {
                    tickerContent(tickerWidth: tickerWidth)
                }

                if tickerPosition == "bottom" {
                    Spacer(minLength: 0)
                }
            }
            .onAppear {
                resetTicker()
            }
            .onChange(of: newsTickerViewModel.articles) { _, _ in
                resetTicker()
            }
            .onChange(of: selectedTickerCategory) { _, newCategory in
                updateTickerSettings()
            }
            .onChange(of: pageSize) { _, newSize in
                updateTickerSettings()
            }
            .onChange(of: selectedTickerCountry) { _, newCountry in
                updateTickerSettings()
            }
        }
    }
    
    private func updateTickerSettings() {
        newsTickerViewModel.changeCategory(to: selectedTickerCategory)
        newsTickerViewModel.changePageSize(to: pageSize)
        newsTickerViewModel.changeCountry(to: selectedTickerCountry)
    }

    // MARK: - Subviews
    
    private func noArticlesView() -> some View {
        Text("No articles available")
            .padding()
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
    
    private func tickerContent(tickerWidth: CGFloat) -> some View {
        HStack(spacing: 30) {
            ForEach(newsTickerViewModel.articles, id: \.id) { article in
                articleView(article: article, tickerWidth: tickerWidth)
            }
        }
        .frame(minWidth: contentWidth)
        .offset(x: offset)
    }

    private func articleView(article: Article, tickerWidth: CGFloat) -> some View {
        Text(article.title)
            .headlineFontSize(size: fontSize)
            .headlineFontColor(fontColor)
            .lineLimit(1)
            .padding()
            .background(Color.yellow.opacity(0.4))
            .fixedSize(horizontal: true, vertical: false)
            .background(GeometryReader { geo in
                Color.clear.onAppear {
                    handleArticleWidth(geo.size.width, tickerWidth: tickerWidth)
                }
            })
            .onTapGesture {
                headlineToDisplay = article.title
            }
    }

    // MARK: - Animation & Logic

    private func resetTicker() {
        contentWidth = 0
        offset = 0
        isAnimating = false
        totalArticlesProcessed = 0
    }

    private func handleArticleWidth(_ articleWidth: CGFloat, tickerWidth: CGFloat) {
        DispatchQueue.main.async {
            if !articleWidth.isNaN && !tickerWidth.isNaN {
                contentWidth += articleWidth
                totalArticlesProcessed += 1
                
                if totalArticlesProcessed == newsTickerViewModel.articles.count && !isAnimating {
                    startTickerAnimation(for: tickerWidth)
                }
            }
        }
    }

    private func startTickerAnimation(for tickerWidth: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true

        let totalWidth = contentWidth + tickerWidth
        offset = tickerWidth

        withAnimation(
            Animation.linear(duration: dynamicAnimationDuration(for: tickerWidth))
                .repeatForever(autoreverses: false)
        ) {
            offset = -totalWidth
        }
    }

    private func dynamicAnimationDuration(for width: CGFloat) -> Double {
        guard width > 0 else { return baseAnimationDuration }
        let speedFactor = contentWidth / width
        return baseAnimationDuration * speedFactor
    }
}

