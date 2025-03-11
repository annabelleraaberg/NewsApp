//
//  KeychainManager.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 21/11/2024.
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    // Based on Apple Developer Documentation on Keychain: https://developer.apple.com/documentation/security/storing-keys-in-the-keychain#Create-a-Query-Dictionary
    // I used kSecClassGenericPassword insetad of kSecClassKey because I didn't need it to be cryptographic.
    func saveAPIKey(_ apiKey: String) -> Bool {
        guard let data = apiKey.data(using: .utf8) else { return false }
        let addquery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apiKey",
            kSecValueData as String: data
        ]
        
        // Delete existing key
        SecItemDelete(addquery as CFDictionary)
        
        let status = SecItemAdd(addquery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retreiveAPIKey() -> String? {
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apiKey",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteAPIKey() -> Bool {
        let deletequery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apiKey"
        ]
        
        let status = SecItemDelete(deletequery as CFDictionary)
        return status == errSecSuccess
    }
}

