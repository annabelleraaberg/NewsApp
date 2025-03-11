//
//  APIKeyViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 06/12/2024.
//

import SwiftUI

class APIKeyViewModel: ObservableObject {
    @Published var apiKey: String = ""
    
    private let keychainService = KeychainService.shared
    
    func saveAPIKey(_ key: String) {
        let success = KeychainService.shared.saveAPIKey(key)
        if success {
            print("API key saved successfully")
            apiKey = key
        } else {
            print("Failed to save API key")
        }
    }
    
    func loadAPIKey() -> String? {
        let key = keychainService.retreiveAPIKey()
        if let key = key {
            apiKey = key
        }
        return key
    }
    
    func clearAPIKey() {
        let success = KeychainService.shared.deleteAPIKey()
        if success {
            print("API key cleared successfully")
            apiKey = ""
        } else {
            print("Failed to clear API key")
        }
    }
}
