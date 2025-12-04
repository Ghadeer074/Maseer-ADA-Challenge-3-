//
//  HistoryPage.swift
//  MaseerApp
//
//  Created by Feda  on 02/12/2025.
//

import SwiftUI
import SwiftData

struct HistoryPage: View {

    // SwiftData query
    @Query(sort: \HistoryItem.date, order: .reverse)
    private var items: [HistoryItem]

    // When user taps a row
    let onSelect: (HistoryItem) -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .trailing, spacing: 20) {

                    Text("السّجلات السابقة")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)

                    ForEach(items) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            HistoryRow(
                                title: item.title,
                                subtitle: formatDate(item.date)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @State var container = try! ModelContainer(for: HistoryItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    return HistoryPage { _ in }
        .modelContainer(container)
}
