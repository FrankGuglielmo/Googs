//
//  Color.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/10/25.
//

import SwiftUI

extension Color {
    /// Initialize a Color from a hex string, e.g., "#FF0000" or "FF0000".
    init(hex: String) {
        // Remove "#" if present
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let length = cleanedHex.count
        let r, g, b: Double
        
        // Handle 6-digit hex (RGB) or 8-digit hex (ARGB)
        if length == 6 {
            r = Double((rgbValue & 0xFF0000) >> 16) / 255
            g = Double((rgbValue & 0x00FF00) >> 8) / 255
            b = Double(rgbValue & 0x0000FF) / 255
        } else {
            // Fallback for unexpected format — set to white
            r = 1.0
            g = 1.0
            b = 1.0
        }
        
        self.init(red: r, green: g, blue: b)
    }
    
    static let ecf2ff = Color(hex: "ECF2FF")
    static let _3E54AC = Color(hex: "3E54AC")
    static let _655DBB = Color(hex: "655DBB")
    static let bface2 = Color(hex: "BFACE2")
    static let ff9e5e = Color(hex: "FF9E5E")
    static let gray747474 = Color(hex: "747474")
    static let f1f0f5 = Color(hex: "F1F0F5")
    
    
    
    
}
