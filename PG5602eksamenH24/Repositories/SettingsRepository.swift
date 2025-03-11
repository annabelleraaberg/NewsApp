//
//  SettingsRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 25/11/2024.
//

import Foundation
import SwiftUICore
import UIKit

struct DefaultSettings {
    static let tickerPosition = "Top"
    static let selectedTickerCategory = "technology"
    static let selectedTickerCountry = "us"
    static let pageSize = 10
    static let showTicker = true
}

class SettingsRepository {
    static let shared = SettingsRepository()
    
    private let userDefaults: UserDefaults
    private let darkModeKey: String = "darkMode"
    private let headlineFontSizeKey: String = "headlineFontSize"
    private let headlineFontColorKey: String = "headlineFontColor"
    
    private let tickerPositionKey: String = "tickerPosition"
    private let showTickerKey: String = "showTicker"
    private let selectedTickerCategoryKey: String = "selectedTickerCategory"
    private let selectedTickerCountryKey: String = "selectTickerCountry"
    private let pageSizeKey = "pageSize"
    
    private init() {
        self.userDefaults = UserDefaults.standard
    }
    
    func saveTickerPosition(_ position: String) {
        userDefaults.set(position, forKey: tickerPositionKey)
        print("Saved ticker position in repository: \(position)")
    }
    
    func loadTickerPosition() -> String {
        return userDefaults.string(forKey: tickerPositionKey) ?? DefaultSettings.tickerPosition
    }
    
    func saveShowTicker(_ showTicker: Bool) {
        userDefaults.set(showTicker, forKey: showTickerKey)
    }
    
    // Ticker is set to true by default
    func loadShowTicker() -> Bool {
        if userDefaults.object(forKey: showTickerKey) == nil {
            return DefaultSettings.showTicker
        }
        return userDefaults.bool(forKey: showTickerKey)
    }
    
    func saveSelectedTickerCategory(_ category: String) {
        userDefaults.set(category, forKey: selectedTickerCategoryKey)
        print("Saved selected ticker category in repository: \(category)")
    }
    
    func loadSelectedTickerCategory() -> String {
        return userDefaults.string(forKey: selectedTickerCategoryKey) ?? DefaultSettings.selectedTickerCategory
    }
    
    func saveSelectedTickerCountry(_ country: String) {
        userDefaults.set(country, forKey: selectedTickerCountryKey)
        print("Saved selected ticker country in repository: \(country)")
    }
    
    func loadSelectedTickerCountry() -> String {
        return userDefaults.string(forKey: selectedTickerCountryKey) ?? DefaultSettings.selectedTickerCountry
    }
    
    func savePageSize(_ size: Int) {
        userDefaults.set(size, forKey: pageSizeKey)
    }
    
    // Counter cannot be 0 and defaults to 10
    func loadPageSize() -> Int {
        let size = userDefaults.integer(forKey: pageSizeKey)
        return size == 0 ? DefaultSettings.pageSize : size
    }
    
    func saveDarkMode(_ isDarkMode: Bool) {
        userDefaults.set(isDarkMode, forKey: darkModeKey)
    }
    
    func loadDarkMode() -> Bool {
        if userDefaults.object(forKey: darkModeKey) == nil {
            return false
        }
        return userDefaults.bool(forKey: darkModeKey)
    }
    
    func saveHeadlineFontSize(_ size: CGFloat) {
        userDefaults.set(size, forKey: headlineFontSizeKey)
        print("Saved ticker font size in repository: \(size)")
    }

    func loadHeadlineFontSize() -> CGFloat {
        return userDefaults.object(forKey: headlineFontSizeKey) as? CGFloat ?? 16.0 
    }
    
    func saveHeadlineFontColor(_ color: Color) {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(color)
        
        // Convert UIColor to Data for storage
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            userDefaults.set(colorData, forKey: headlineFontColorKey)
        }
        print("Saved ticker font color in repository: \(color)")
    }
    
    func loadHeadlineFontColor() -> Color {
        // Retrieve the stored color data
        guard let colorData = userDefaults.data(forKey: headlineFontColorKey),
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            return Color.black 
        }
        
        // Convert UIColor back to Color
        return Color(uiColor)
    }
}
