//
//  HistoryInfoView.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 09/06/1447 AH.
//

import SwiftUI
import SwiftData

struct HistoryInfoView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteAlert = false

    let item: HistoryItem

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {

                Spacer().frame(height: 50)

                GlassEffectContainer {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .trailing, spacing: 16) {

                            Spacer().frame(height: 70)

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(item.title)
                                    .font(.custom("Geeza Pro", size: 30).bold())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal, 32)

                                Text(formatDate(item.date))
                                    .font(.custom("Geeza Pro", size: 18).bold())
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.trailing)
                                    .padding(.horizontal, 32)
                            }

                            Text(item.details)
                                .font(.custom("Geeza Pro", size: 20).bold())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal, 32)
                                .padding(.top, 18)

                            Spacer()

                            Button {
                                showDeleteAlert = true
                            } label: {
                                Text("Delete history")
                                    .font(.custom("Geeza Pro", size: 20).bold())
                                    .foregroundColor(.brightRed)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .glassEffect(.clear.tint(.darkerGray.opacity(1)))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            .accessibilityLabel("Delete record")
                            .accessibilityHint("this record will be delerted permantly")
                            .accessibilityIdentifier("delete_history_button")
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                                .font(.custom("Geeza Pro", size: 18).bold())
                                .foregroundColor(.white)
                                .frame(width: 81, height: 41)
                        }
                        .glassEffect(.clear.tint(Color.darkerGray.opacity(1)))
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        .accessibilityLabel("Close")
                        .accessibilityHint("Back to history")
                        .accessibilityIdentifier("close_history_button")
                    }
                }
                .frame(width: 396, height: 792)
                .glassEffect(
                    .clear.tint(Color.black.opacity(0.1)),
                    in: .rect(cornerRadius: 34)
                )

                Spacer()
            }
        }
        .animation(.easeInOut, value: showDeleteAlert)
        .alert(
            "Delete record",
            isPresented: $showDeleteAlert,
            actions: {
                Button("Cancel", role: .cancel) { }

                Button("Delete", role: .destructive) {
                    modelContext.delete(item)
                    dismiss()
                }
            },
            message: {
                Text("Are you sure you want to delete this record? If you are sure, press 'Delete'. If you don't want to delete it, press 'Cancel'.")            }
        )
//        .accessibilityLanguage("ar")
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

    let sample = HistoryItem(
        title: "Coffee shop",
        details: "An experimental description of the surroundings of the place."
    )

    HistoryInfoView(item: sample)
        .modelContainer(container)
}
