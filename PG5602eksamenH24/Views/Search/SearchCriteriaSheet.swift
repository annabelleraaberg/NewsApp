//
//  SearchCriteriaSheet.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 06/12/2024.
//

import SwiftUI

struct SearchCriteriaSheet: View {
    @Binding var query: String
    @Binding var searchIn: [String]
    @Binding var sortSearchOption: SearchViewModel.SortSearchOption
    @Binding var domains: [String]
    @Binding var excludeDomains: [String]
    @Binding var isPresented: Bool
    @Binding var note: String?
    @Binding var selectedLanguage: String
    @Binding var fromDate: Date
    @Binding var toDate: Date
    
    var onSearch: () -> Void
    
    @ObservedObject var searchViewModel: SearchViewModel
    
    @State private var selectedDomain: String?
    @State private var selectedExcludeDomain: String?
    @State private var filteredKeywords: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Advanced Search")
                        .font(.headline)
                    
                    SearchFieldView(query: $query, filteredKeywords: $filteredKeywords, searchViewModel: searchViewModel)
                    
                    LanguagePickerView(selectedLanguage: $selectedLanguage)
                    
                    SearchFieldsView(searchIn: $searchIn)
                    
                    DatePickersView(fromDate: $fromDate, toDate: $toDate)
                    
                    SortByPickerView(sortSearchOption: $sortSearchOption)
                    
                    DomainPickerView(
                        selectedDomain: $selectedDomain,
                        selectedExcludeDomain: $selectedExcludeDomain,
                        domains: $domains,
                        excludeDomains: $excludeDomains,
                        searchViewModel: searchViewModel
                    )
                    
                    AddNoteView(note: $note)
                    
                    SearchButton(onSearch: {
                        if !query.isEmpty {
                            searchViewModel.saveSearch(Search(keyword: query, notes: note))
                        }
                        onSearch()
                    }, query: query, isPresented: $isPresented)
                }
                .padding()
                .onAppear {
                    if searchViewModel.sources.isEmpty {
                        searchViewModel.fetchSources()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

struct SearchFieldView: View {
    @Binding var query: String
    @Binding var filteredKeywords: [String]
    @ObservedObject var searchViewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Search...", text: $query)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if query.isEmpty {
                        query = searchViewModel.lastSearchQuery
                    }
                }
                .onChange(of: query) { oldQuery, newQuery in
                    filteredKeywords = searchViewModel.savedKeywords.filter {
                        $0.lowercased().contains(newQuery.lowercased())
                    }
                }
            
            if !filteredKeywords.isEmpty {
                ScrollView {
                    VStack {
                        ForEach(filteredKeywords, id: \.self) { keyword in
                            Button(action: {
                                query = keyword
                                filteredKeywords = []
                            }) {
                                Text(keyword)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .border(Color.secondary, width: 1)
            }
        }
    }
}

struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    
    var body: some View {
        Text("Select Language")
            .font(.headline)
        Picker("Language", selection: $selectedLanguage) {
            Text("English").tag("en")
            Text("Arabic").tag("ar")
            Text("Spanish").tag("es")
            Text("French").tag("fr")
            Text("German").tag("de")
            Text("Hebrew").tag("he")
            Text("Italian").tag("it")
            Text("Dutch").tag("nl")
            Text("Norwegian").tag("no")
            Text("Polish").tag("pt")
            Text("Russian").tag("ru")
            Text("Swedish").tag("sv")
            Text("Chinese").tag("zh")
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct SearchFieldsView: View {
    @Binding var searchIn: [String]
    
    var body: some View {
        Text("Choose fields to search in:")
            .font(.headline)
        Text("Choose one or multiple fields to search in.")
        HStack {
            SearchOptionButton(field: "title", searchIn: $searchIn)
            SearchOptionButton(field: "description", searchIn: $searchIn)
            SearchOptionButton(field: "content", searchIn: $searchIn)
        }
    }
}

struct DatePickersView: View {
    @Binding var fromDate: Date
    @Binding var toDate: Date
    
    var body: some View {
        Text("Limit the search results to dates:")
            .font(.headline)
        DatePicker("From Date", selection: $fromDate, displayedComponents: [.date])
            .datePickerStyle(.compact)
        DatePicker("To Date", selection: $toDate, displayedComponents: [.date])
            .datePickerStyle(.compact)
    }
}

struct SortByPickerView: View {
    @Binding var sortSearchOption: SearchViewModel.SortSearchOption
    
    var body: some View {
        Text("Sort search results by:")
            .font(.headline)
        Text("You can choose on of the options below to sort search results by relevance, popularity or date.")
        Picker("Sort by", selection: $sortSearchOption) {
            Text("Relevance").tag(SearchViewModel.SortSearchOption.relevance)
            Text("Popularity").tag(SearchViewModel.SortSearchOption.popularity)
            Text("Date").tag(SearchViewModel.SortSearchOption.date)
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
    }
}

struct DomainPickerView: View {
    @Binding var selectedDomain: String?
    @Binding var selectedExcludeDomain: String?
    @Binding var domains: [String]
    @Binding var excludeDomains: [String]
    @ObservedObject var searchViewModel: SearchViewModel
    
    var body: some View {
        Text("Include or exclude domains")
            .font(.headline)
        Text("Included domains: \(domains.joined(separator: ", "))")
        Picker("Select Domain", selection: $selectedDomain) {
            ForEach(searchViewModel.sources, id: \.id) { source in
                Text(source.name).tag(source.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .onChange(of: selectedDomain) { oldDomain, newDomain in
            if let domain = newDomain, !domains.contains(domain) {
                domains.append(domain)
            }
        }
        
        Text("Excluded domains: \(excludeDomains.joined(separator: ", "))")
        Picker("Select Excluded Domain", selection: $selectedExcludeDomain) {
            ForEach(searchViewModel.sources, id: \.id) { source in
                Text(source.name).tag(source.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .onChange(of: selectedExcludeDomain) { oldDomain, newDomain in
            if let excludedDomain = newDomain, !excludeDomains.contains(excludedDomain) {
                excludeDomains.append(excludedDomain)
            }
        }
    }
}

struct AddNoteView: View {
    @Binding var note: String?
    
    var body: some View {
        Text("Add a note")
            .font(.headline)
        Text("Saved notes can be found in Saved Notes in Settings")
            .font(.footnote)
        Section(header: Text("Note")) {
            TextField("Notes", text: Binding(
                get: { note ?? "" },
                set: { note = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .padding()
        }
    }
}

struct SearchButton: View {
    var onSearch: () -> Void
    var query: String
    @Binding var isPresented: Bool
    
    var body: some View {
        Button("Search") {
            if !query.isEmpty {
                onSearch()
                isPresented = false
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundStyle(.white)
        .cornerRadius(8)
    }
}

struct SearchOptionButton: View {
    var field: String
    @Binding var searchIn: [String]
    
    var body: some View {
        Button(action: {
            toggleSearchIn(field: field)
        }) {
            HStack {
                if searchIn.contains(field) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Text(field.capitalized)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(2)
        }
    }
    
    private func toggleSearchIn(field: String) {
        if searchIn.contains(field) {
            searchIn.removeAll { $0 == field }
        } else {
            searchIn.append(field)
        }
    }
}
