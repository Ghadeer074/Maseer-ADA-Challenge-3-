//
//  HistoryPage.swift
//  MaseerApp
//
//  Created by Feda  on 02/12/2025.
//


import SwiftUI
import SwiftData

struct HistoryPage: View {

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \HistoryItem.date, order: .reverse)
    private var items: [HistoryItem]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .trailing, spacing: 20) {

                        // عنوان الصفحة كبير داخل المحتوى
                        Text("السّجلات السابقة")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)

                        ForEach(items) { item in
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .trailing)

                                Text(formatDate(item.date))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.white.opacity(0.06))   // خلفية شبه شفافة
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1) // حد خفيف
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                            Text("رجوع")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // تنسيق التاريخ للنص
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#Preview {
    HistoryPage()
        .modelContainer(for: HistoryItem.self, inMemory: true)
}
