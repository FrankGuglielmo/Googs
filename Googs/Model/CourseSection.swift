//
//  CourseSection.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-04-14.
//

import SwiftUI

struct CourseSection: Identifiable {
    var id = UUID()
    var title: String
    var caption: String
    var color: Color
    var image: Image
}

var courseSections = [
    CourseSection(title: "Advanced Custom Layout", caption: "SwiftUI for iOS 15", color: Color(hex: "9CC5FF"), image: Image("Topic 2")),
    CourseSection(title: "Coding the Home View", caption: "SwiftUI Concurrency", color: Color(hex: "6E6AE8"), image: Image("Topic 1")),
    CourseSection(title: "Colors and Shadows", caption: "SwiftUI Visual Editor", color: Color(hex: "005FE7"), image: Image("Topic 2")),
    CourseSection(title: "UI Design for iPad", caption: "Graphical User Interface", color: Color(hex: "BBA6FF"), image: Image("Topic 1")),
]
