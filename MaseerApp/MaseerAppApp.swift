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
                .modelContainer(for: HistoryItem.self)
        }
    }
}
