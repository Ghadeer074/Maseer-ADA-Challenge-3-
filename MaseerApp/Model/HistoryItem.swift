//
//  HistoryItem.swift
//  MaseerApp
//
//  Created by Feda  on 02/12/2025.
//


import Foundation
import SwiftData

@Model
final class HistoryItem {
    @Attribute(.unique) var id: UUID
    var title: String      // اسم المكان
    var date: Date        // تاريخ الحفظ

    init(title: String, date: Date = .now) {
        self.id = UUID()
        self.title = title
        self.date = date
    }
}
