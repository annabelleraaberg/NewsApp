//
//  ColorSchemeModifier.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import SwiftUI

struct ColorSchemeModifier: ViewModifier {
    @Binding var isDarkMode: Bool
    
    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

extension View {
    func toggleColorScheme(isDarkMode: Binding<Bool>) -> some View {
        self.modifier(ColorSchemeModifier(isDarkMode: isDarkMode))
    }
}

//#Preview {
//    //ColorSchemeModifier()
//}
