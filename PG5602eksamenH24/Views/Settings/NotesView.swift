//
//  NotesView.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    
    @StateObject var notesViewModel: NotesViewModel
    @StateObject var categoryViewModel: CategoryViewModel
    
    @State private var notesText: String = ""
    @State private var isEditing: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                
                if !searchViewModel.searches.isEmpty {
                    savedSearchesSection
                } else {
                    noSavedSearchesSection
                }
                
                countryInformationSection
                
                if let selectedCountry = notesViewModel.getSelectedCountry(),
                   let notes = selectedCountry.notes {
                    countryNotesSection(selectedCountry, notes: notes)
                } else {
                    noNotesAvailableSection
                }
                
                notesInputSection
                
                actionsSection
                
                categoryNotesSection
                
                    .navigationBarTitle("Saved Notes")
            }
            .onAppear {
                onAppearActions()
            }
            .alert(isPresented: $showAlert) {
                successAlert
            }
        }
        .padding()
    }
}

// MARK: - Subviews
extension NotesView {
    private var headerSection: some View {
        Text("Saved Searches with notes")
            .font(.headline)
    }
    
    private var savedSearchesSection: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(searchViewModel.searches, id: \.id) { search in
                        VStack(alignment: .leading) {
                            Text(search.keyword)
                                .font(.headline)
                            if let notes = search.notes {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(10)
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray)
                        .frame(maxHeight: .infinity, alignment: .bottom),
                    alignment: .bottom
                )
            }
            .frame(height: 200)
        }
        .padding(.bottom)
    }
    
    private var noSavedSearchesSection: some View {
        Text("No saved searches found.")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.bottom)
    }
    
    private var countryInformationSection: some View {
        VStack {
            Text("Country Information")
                .font(.headline)
            
            Text("Country Notes")
                .font(.subheadline)
            
            
            Picker("Select a Country", selection: $notesViewModel.selectedCountry) {
                ForEach(notesViewModel.countries, id: \.code) { country in
                    Text(country.name).tag(country.code as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: notesViewModel.selectedCountry) { _, newValue in
                if let countryCode = newValue {
                    loadCountryNotes(for: countryCode)
                }
            }
        }
    }
    
    private func countryNotesSection(_ selectedCountry: Country, notes: String) -> some View {
        VStack(alignment: .leading) {
            Text("Notes for \(selectedCountry.name):")
                .font(.headline)
                .padding(.top)
            
            Text(notes)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text("Last updated: \(selectedCountry.updatedAt.formattedDate())")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Text("Created on: \(selectedCountry.createdAt.formattedDate())")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
    
    private var noNotesAvailableSection: some View {
        Text("No notes available.")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.bottom)
    }
    
    private var notesInputSection: some View {
        TextField("Enter notes here...", text: $notesText, onEditingChanged: { editing in
            isEditing = editing
        })
        .textFieldStyle(.roundedBorder)
        .padding(.bottom)
    }
    
    private var actionsSection: some View {
        HStack {
            Button("Save Notes") {
                Task {
                    await saveCountryNotes()
                }
            }
            .padding()
            
            Button("Delete Notes") {
                Task {
                    await deleteCountryNotes()
                }
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding(.bottom)
    }
    
    private var categoryNotesSection: some View {
        VStack(alignment: .leading) {
            Text("Categories with Notes")
                .font(.headline)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(categoryViewModel.categoriesWithNotes, id: \.id) { category in
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            if let notes = category.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray)
                        .frame(maxHeight: .infinity, alignment: .bottom),
                    alignment: .bottom
                )
            }
            .frame(height: 200)
        }
        .padding(.bottom)
    }
}

// MARK: - Helper Methods
extension NotesView {
    private func loadCountryNotes(for countryCode: String) {
        if let country = notesViewModel.countries.first(where: { $0.code == countryCode }) {
            notesText = country.notes ?? "No notes yet"
        }
    }
    
    private func saveCountryNotes() async {
        if let selectedCountryCode = notesViewModel.selectedCountry,
           let country = notesViewModel.countries.first(where: { $0.code == selectedCountryCode }) {
            await notesViewModel.saveNotes(for: country, newNotes: notesText)
        }
    }
    
    private func deleteCountryNotes() async {
        isEditing = false
        
        if let selectedCountryCode = notesViewModel.selectedCountry,
           let country = notesViewModel.countries.first(where: { $0.code == selectedCountryCode }) {
            await notesViewModel.deleteNotes(for: country)
        }
        notesText = ""
        showAlert = true
    }
    
    private func onAppearActions() {
        searchViewModel.fetchSearchesWithNotes()
        categoryViewModel.fetchCategoriesWithNotes()
    }
    
    private var successAlert: Alert {
        Alert(
            title: Text("Success"),
            message: Text("The note was successfully deleted."),
            dismissButton: .default(Text("OK"))
        )
    }
}


//#Preview {
//    NotesView()
//}
