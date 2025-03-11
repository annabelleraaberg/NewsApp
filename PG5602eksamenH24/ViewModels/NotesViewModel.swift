//
//  NotesViewModel.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import Foundation

@MainActor
class NotesViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var selectedCountry: String?
    
    private var countryRepository: CountryRepository

    init(countryRepository: CountryRepository) {
        self.countryRepository = countryRepository
        Task {
            await loadCountries()
        }
    }

    func loadCountries() async {
        do {
            let localCountries = try await countryRepository.loadAllCountries()
            
            if localCountries.isEmpty {
                // If no countries are in the local database, fetch from API
                print("No countries in local DB, fetching from API...")
                if let fetchedCountries = await countryRepository.fetchCountries() {
                    // Store fetched countries in the local database
                    await countryRepository.saveCountries(fetchedCountries)
                    
                    DispatchQueue.main.async {
                        self.countries = fetchedCountries
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.countries = localCountries
                }
            }
        } catch {
            print("Error loading countries: \(error)")
        }
    }
    
    func selectCountry(country: Country) {
        self.selectedCountry = country.code
        print("Selected country for notes: \(country.name)")
    }
    
    func getSelectedCountry() -> Country? {
        if let selectedCode = selectedCountry {
            return countries.first { $0.code == selectedCode }
        }
        return nil
    }
    
    func saveNotes(for country: Country, newNotes: String) async {
        country.notes = newNotes
        country.updateTimestamp()
        await countryRepository.saveCountries([country])
        print("Country notes saved for: \(country.name)")
    }

    
    // Delete notes for the selected country
    func deleteNotes(for country: Country) async {
        country.notes = nil
        country.updateTimestamp()
        await countryRepository.saveCountries([country])
        
        print("Country notes deleted for: \(country.name)")
    }
}
