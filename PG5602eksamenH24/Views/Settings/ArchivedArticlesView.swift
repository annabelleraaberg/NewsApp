//
//  ArchivedArticlesView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 25/11/2024.
//

import SwiftUI

struct ArchivedArticlesView: View {
    @ObservedObject var viewModel: ArticlesViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    var categoryRepository: CategoryRepository
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.archivedArticles.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "archivebox.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.gray)
                            .padding(.bottom, 16)
                        
                        Text("No Archived Articles")
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.archivedArticles, id: \.self) { article in
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
                                    Spacer()
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    viewModel.deleteArticle(article)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    viewModel.restoreArticle(article)
                                }) {
                                    Label("Restore", systemImage: "arrow.uturn.backward.circle")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadArchivedArticles()
            }
        }
    }
}

//#Preview {
//    //ArchivedArticlesView()
//}
