//
//  HeadlineFontSizeModifier.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import SwiftUI

struct HeadlineFontSizeModifier: ViewModifier {
    let fontSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize))
    }
}

extension View {
    func headlineFontSize(size: CGFloat) -> some View {
        self.modifier(HeadlineFontSizeModifier(fontSize: size))
    }
}


//#Preview {
//    HeadlineFontSizeModifier()
//}
