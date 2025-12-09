//
//  MaseerAppApp.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 09/06/1447 AH.
//

import SwiftUI
import SwiftData
@main
struct MaseerAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, Locale(identifier: "ar"))
                .environment(\.layoutDirection, .rightToLeft)
                .modelContainer(for: HistoryItem.self)
        }
    }
}
