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
    var title: String      // اسم المكان أو نص مختصر
    var date: Date        // تاريخ الحفظ
    var details: String   // الوصف التفصيلي للمحيط (من الكاميرا)

    init(title: String, details: String, date: Date = .now) {
        self.id = UUID()
        self.title = title
        self.details = details
        self.date = date
    }
}
