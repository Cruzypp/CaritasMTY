//
//  FontTheme.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 05/11/25.
//

import SwiftUI
import UIKit

enum GothamWeight: String {
    case thin = "Gotham-Thin"
    case regular = "Gotham-Regular"
    case bold = "Gotham-Bold"
    var name: String { rawValue }
}

extension Font {
    /// Uso: .font(.gotham(.bold, style: .title2))
    static func gotham(_ weight: GothamWeight = .regular, style: TextStyle) -> Font {
        // tamaño base “oficial” del estilo (ya respeta la categoría actual del usuario)
        let base = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        return .custom(weight.name, size: base, relativeTo: style)
    }
}

extension Font.TextStyle {
    /// Mapea SwiftUI → UIKit para usar preferredFont
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title:      return .title1
        case .title2:     return .title2
        case .title3:     return .title3
        case .headline:   return .headline
        case .subheadline:return .subheadline
        case .body:       return .body
        case .callout:    return .callout
        case .footnote:   return .footnote
        case .caption:    return .caption1
        case .caption2:   return .caption2
        @unknown default: return .body
        }
    }
}
