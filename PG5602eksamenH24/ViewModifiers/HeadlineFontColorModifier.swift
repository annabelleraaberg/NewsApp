//
//  HeadlineFontColorModifier.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import SwiftUI

struct HeadlineFontColorModifier: ViewModifier {
    let fontColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(fontColor)
    }
}

extension View {
    func headlineFontColor(_ color: Color) -> some View {
        self.modifier(HeadlineFontColorModifier(fontColor: color))
    }
}

//#Preview {
//    HeadlineFontColorModifier()
//}
