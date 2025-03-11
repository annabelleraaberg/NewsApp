//
//  Date+Extension.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import Foundation

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
