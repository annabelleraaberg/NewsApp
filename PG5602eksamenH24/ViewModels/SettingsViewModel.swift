//
//  SettingsViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 04/12/2024.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var tickerPosition: String
    @Published var showTicker: Bool
    @Published var selectedTickerCategory: String
    @Published var selectedTickerCountry: String
    @Published var pageSize: Int
    @Published var isDarkMode: Bool
    @Published var headlineFontSize: CGFloat
    @Published var headlineFontColor: Color
    
    private var settingsRepository: SettingsRepository
    
    init(settingsRepository: SettingsRepository = SettingsRepository.shared) {
        self.settingsRepository = settingsRepository
        self.tickerPosition = settingsRepository.loadTickerPosition()
        self.showTicker = settingsRepository.loadShowTicker()
        self.selectedTickerCategory = settingsRepository.loadSelectedTickerCategory()
        self.selectedTickerCountry = settingsRepository.loadSelectedTickerCountry()
        self.pageSize = settingsRepository.loadPageSize()
        self.isDarkMode = settingsRepository.loadDarkMode()
        self.headlineFontSize = settingsRepository.loadHeadlineFontSize()
        self.headlineFontColor = settingsRepository.loadHeadlineFontColor()
    }
    
    func saveAllPreferences() {
        settingsRepository.saveTickerPosition(tickerPosition)
        settingsRepository.saveShowTicker(showTicker)
        settingsRepository.saveSelectedTickerCategory(selectedTickerCategory)
        settingsRepository.saveSelectedTickerCountry(selectedTickerCountry)
        settingsRepository.savePageSize(pageSize)
        settingsRepository.saveDarkMode(isDarkMode)
        settingsRepository.saveHeadlineFontSize(headlineFontSize)
        settingsRepository.saveHeadlineFontColor(headlineFontColor)
        print("Preferences saved! ticker position: \(tickerPosition), show ticker: \(showTicker), selected ticker category: \(selectedTickerCategory), selected ticker country: \(selectedTickerCountry), news ticker count: \(pageSize), dark mode: \(isDarkMode), font size: \(headlineFontSize), font color: \(headlineFontColor)")
    }
}


