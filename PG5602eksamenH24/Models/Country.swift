//
//  Country.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 22/11/2024.
//

import Foundation
import SwiftData

@Model
class Country: Identifiable, Decodable, Hashable {
    var id: String {code}
    var name: String
    var code: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedCode = try container.decode(String.self, forKey: .code)
        self.code = decodedCode
        self.name = Country.countryName(fromCode: decodedCode) 
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    init(name: String, code: String, notes: String? = nil) {
        self.name = name
        self.code = code
        self.notes = notes
    }
    
    private enum CodingKeys: String, CodingKey {
        case code = "country"
        case notes
    }
    
    func updateTimestamp() {
        updatedAt = Date()
    }
    
    static func countryName(fromCode code: String) -> String {
        let countryMapping: [String: String] = [
            "us" : "United States",
            "gb" : "United Kingdom",
            "de" : "Germany",
            "fr" : "France",
            "it" : "Italy",
            "ae" : "United Arab Emirates",
            "ar" : "Argentina",
            "at" : "Austria",
            "au" : "Australia",
            "be" : "Belgium",
            "bg" : "Bulgaria",
            "br" : "Brazil",
            "ca" : "Canada",
            "ch" : "Switzerland",
            "co" : "Colombia",
            "cu" : "Cuba",
            "cn" : "China",
            "cz" : "Czech Republic",
            "eg" : "Egypt",
            "gr" : "Greece",
            "hk" : "Hong Kong",
            "hu" : "Hungary",
            "id" : "Indonesia",
            "ie" : "Ireland",
            "il" : "Israel",
            "in" : "India",
            "jp" : "Japan",
            "kr" : "South Korea",
            "lt" : "Lithuania",
            "lv" : "Latvia",
            "ma" : "Morocco",
            "mx" : "Mexico",
            "my" : "Malaysia",
            "ng" : "Nigeria",
            "nl" : "Netherlands",
            "no" : "Norway",
            "nz" : "New Zealand",
            "ph" : "Philippines",
            "pl" : "Poland",
            "pt" : "Portugal",
            "ro" : "Romania",
            "rs" : "Serbia",
            "ru" : "Russia",
            "sa" : "Saudi Arabia",
            "se" : "Sweden",
            "sg" : "Singapore",
            "si" : "Slovenia",
            "sk" : "Slovakia",
            "th" : "Thailand",
            "tr" : "Turkey",
            "tw" : "Taiwan",
            "ua" : "Ukraine",
            "ve" : "Venezuela",
            "za" : "South Africa",
        ]
        return countryMapping[code] ?? code.uppercased()
    }
    
    // Consider countries equal if their codes match on left and right side
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }
    
    // Uses the country code for hashing
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
