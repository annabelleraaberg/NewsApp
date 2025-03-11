//
//  CountryRepository.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 05/12/2024.
//

import Foundation
import SwiftData

@MainActor
class CountryRepository {
    private var context: ModelContext
    private let newsService: NewsService
    
    init(context: ModelContext, newsService: NewsService) {
        self.context = context
        self.newsService = newsService
    }
    
    func saveCountries(_ countries: [Country]) async {
        for country in countries {
            if loadCountry(byCode: country.code) == nil {
                context.insert(country)
            }
        }
        do {
            try context.save()
        } catch {
            print("Error saving countries: \(error)")
        }
    }
    
    func loadCountry(byCode code: String) -> Country? {
        do {
            let countries = try context.fetch(FetchDescriptor<Country>())
            return countries.first { $0.code == code }
        } catch {
            print("Error fetching countries: \(error)")
            return nil
        }
    }
    
    func loadAllCountries() async throws -> [Country] {
        do {
            let descriptor = FetchDescriptor<Country>()
            let countries = try context.fetch(descriptor)
            return countries
        } catch {
            throw error
        }
    }
    
    func fetchCountries() async -> [Country]? {
        return await newsService.fetchCountries()
    }
    
    func updateNotes(for countryCode: String, newNotes: String) async {
        if let country = loadCountry(byCode: countryCode) {
            country.notes = newNotes
            country.updateTimestamp()
            await saveCountries([country])
        }
    }
    
    func deleteNotes(for countryCode: String) async {
        if let country = loadCountry(byCode: countryCode) {
            country.notes = nil
            country.updateTimestamp() 
            await saveCountries([country])
        }
    }
}
