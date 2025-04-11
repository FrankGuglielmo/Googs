//
//  CustomFont.swift
//  Googs
//
//  Created by Frank Guglielmo on 3/27/25.
//

import SwiftUI

struct CustomFont: ViewModifier {
    var textStyle: TextStyle
    
    var name: String {
        switch textStyle {
        case .title:
            return "Poppins Bold"
        case .body:
            return "Inter Regular"
        }
    }
    
    var size: CGFloat {
        switch textStyle {
        case .title:
            return 28
        case .body:
            return 17
        }
    }
    
    var relativeTo: Font.TextStyle {
        switch textStyle {
        case .title:
            return .title
        case .body:
            return .body
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Inter Regular", size: 17, relativeTo: .body))
    }
}

extension View {
    func customFont(_ textStyle: TextStyle) -> some View {
        modifier(CustomFont(textStyle: textStyle))
    }
}

enum TextStyle {
    case title
    case body
    
}
