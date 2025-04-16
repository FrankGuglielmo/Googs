//
//  CustomFont.swift
//  Googs
//
//  Created by Frank Guglielmo on 3/27/25.
//

import SwiftUI

struct CustomFont: ViewModifier {
    var textStyle: TextStyle
    var modifiers: [Modifiers] = []
    
    var name: String {
        switch textStyle {
        case .title, .title2, .title3, .largeTitle:
            return "Inter SemiBold"
        case .headline, .footnote2, .subheadline2, .callout, .caption2:
            return "Inter SemiBold"
        case .body, .subheadline, .footnote, .caption:
            return "Inter Regular"
        }
    }
    
    var size: CGFloat {
        switch textStyle {
        case .largeTitle:
            return 45
        case .title:
            return 28
        case .callout:
            return 20
        case .body:
            return 17
        case .title2:
            return 24
        case .title3:
            return 20
        case .headline:
            return 17
        case .subheadline:
            return 15
        case .subheadline2:
            return 15
        case .footnote:
            return 13
        case .footnote2:
            return 13
        case .caption:
            return 12
        case .caption2:
            return 12
        }
    }
    
    var relative: Font.TextStyle {
        switch textStyle {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .callout:
            return .callout
        case .body:
            return .body
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .subheadline2:
            return .subheadline
        case .footnote:
            return .footnote
        case .footnote2:
            return .footnote
        case .caption:
            return .caption
        case .caption2:
            return .caption 
        }
    }
    
    func body(content: Content) -> some View {
            let color: Color? = modifiers.contains(.disregardsLightMode)
                ? .white
                : (modifiers.contains(.disregardsDarkMode) ? .black : nil)
            
            return content
                .font(.custom(name, size: size, relativeTo: relative))
                .modifier(PermanentColor(color: color))
        }
    
    
}

extension View {
    func customFont(_ textStyle: TextStyle, modifiers: [Modifiers] = []) -> some View {
        modifier(CustomFont(textStyle: textStyle, modifiers: modifiers))
    }
}

enum TextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case subheadline2
    case footnote
    case footnote2
    case caption
    case caption2
    case callout
    case body
    
}

enum Modifiers {
    case disregardsLightMode
    case disregardsDarkMode
}

struct PermanentColor: ViewModifier {
    let color: Color?
    
    func body(content: Content) -> some View {
        Group {
            if let permanentColor = color {
                content.foregroundStyle(permanentColor)
            } else {
                content
            }
        }
    }
}
