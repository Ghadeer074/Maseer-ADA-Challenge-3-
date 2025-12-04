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
            Color.black.ignoresSafeArea()

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
                                Text("حذف السجّل")
                                    .font(.custom("Geeza Pro", size: 20).bold())
                                    .foregroundColor(.brightRed)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .glassEffect(.clear.tint(.darkerGray.opacity(1)))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("إغلاق")
                                .font(.custom("Geeza Pro", size: 18).bold())
                                .foregroundColor(.white)
                                .frame(width: 81, height: 41)
                        }
                        .glassEffect(.clear.tint(Color.darkerGray.opacity(1)))
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
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
            "حذف السجّل",
            isPresented: $showDeleteAlert,
            actions: {
                Button("تراجع", role: .cancel) { }

                Button("حذف", role: .destructive) {
                    modelContext.delete(item)
                    dismiss()
                }
            },
            message: {
                Text("هل أنت متأكد أنك تريد حذف هذا السّجل؟ إذا كنت متأكدًا اضغط “حذف”، وإذا كنت لا تريد الحذف اضغط “تراجع”.")
            }
        )
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
        title: "محل القهوة الأبيض",
        details: "وصف تجريبي للمحيط حول المكان."
    )

    return HistoryInfoView(item: sample)
        .modelContainer(container)
}
