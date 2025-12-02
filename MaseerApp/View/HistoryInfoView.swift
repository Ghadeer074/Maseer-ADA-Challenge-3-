//
//  HistoryInfoView.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 09/06/1447 AH.
//

import SwiftUI

// Static Text temporarily

let Title: String = "محل القهوة الأبيض"
let dateText: String = "٢٠ ذو الحجة ١٤٤٧"
let descriptionText: String = """
أمامك على بُعد خطوتين شجرة خضراء متوسطة الطول، وعلى بُعد ثمانية خطوات هناك مجموعة كراسي بيضاء مقسمة حول طاولتين رخامية بيضاء أيضًا،
الطريق الرئيسي على بُعد خمسة عشر خطوة منك.
"""

//  Main Screen

struct HistoryInfoView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
               
                Spacer().frame(height: 50)

                GlassEffectContainer {
                    ZStack {
                        // Content column (title, date, description, delete button)
                        VStack(alignment: .trailing, spacing: 16) {

                            Spacer().frame(height: 70) // space under close button

                            // Title + date
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(Title)
                                    .font(.custom("Geeza Pro", size: 30).bold())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 26)
                                    .padding(.trailing, 32)

                                Text(dateText)
                                    .font(.custom("Geeza Pro", size: 18).bold())
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 32)
                            }

                            // Description
                            Text(descriptionText)
                                .font(.custom("Geeza Pro", size: 20).bold())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 32)
                                .padding(.top, 18)

                            Spacer()

                            // Bottom delete button (inside the container)
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

                        // Close button overlay (top-right)
                        VStack {
                            HStack {
                                Spacer()

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
                                .padding(.trailing, 24)
                            }

                            Spacer()
                        }
                    }
                }
                .frame(width: 396, height: 792)
                .glassEffect(
                    .clear.tint(Color.black.opacity(0.1)),
                    in: .rect(cornerRadius: 34)
                )

                Spacer() // keeps whole card in same place visually
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .animation(.easeInOut, value: showDeleteAlert)
       
        .alert(
            "حذف السجل",
            isPresented: $showDeleteAlert,
            actions: {
                Button("تراجع", role: .cancel) {
                    // just dismiss alert
                }

                Button("حذف", role: .destructive) {
                    // TODO: hook to your ViewModel delete
                    dismiss()
                }
            },
            message: {
                Text("هل أنت متأكد أنك تريد حذف سجل \"\(Title)\"؟")
            }
        )
    }
}

// Preview

#Preview {
    HistoryInfoView()
}
