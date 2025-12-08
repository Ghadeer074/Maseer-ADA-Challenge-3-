//
//  RootView.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 13/06/1447 AH.
//

import SwiftUI
import SwiftData
import CoreLocation

// Screens for NavigationStack
enum AppScreen: Hashable {
    case locating
    case camera(CLLocation?)
    case history
    case historyDetail(HistoryItem)
}

struct RootView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var path: [AppScreen] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomepageView(
                onStart: { path.append(.locating) },
                onShowHistory: { path.append(.history) }
            )
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {

                case .locating:
                    LoadingLocationView{ location in
                        // when locating is done, go to camera and pass location
                        path.append(.camera(location))
                    }

                case .camera(let location):
                    AICamView(
                        userLocation: location,
                        onFinish: { description in
                            // 1) SAVE to SwiftData
                            let item = HistoryItem(
                                title: description,
                                details: description
                            )
                            modelContext.insert(item)

                            // 2) Return to Homepage (pop to root)
                            path = []
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                case .history:
                    HistoryPage { item in
                        path.append(.historyDetail(item))
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                if !path.isEmpty { path.removeLast() }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.backward")
                                        .accessibilityHidden(true)
                                    Text("رجوع")
                                }
                            }
                            .accessibilityLabel("رجوع")
                            .accessibilityHint("العودة الى الصفحة الرئيسيه من السجّلات السابقة")
                        }
                    }

                case .historyDetail(let item):
                    HistoryInfoView(item: item)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

