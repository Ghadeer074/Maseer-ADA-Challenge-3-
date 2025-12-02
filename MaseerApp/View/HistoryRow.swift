//
//  HistoryRow.swift
//  MaseerApp
//
//  Created by Feda  on 02/12/2025.
//


import SwiftUI

struct HistoryRow: View {
    let title: String
    let subtitle: String   // مثلاً التاريخ كنص

    var body: some View {
        ZStack {
            // خلفية زجاجية (Glassy)
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .background(
                    Color.white.opacity(0.05)
                        .blur(radius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            VStack(alignment: .trailing, spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.trailing)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
    }
}
