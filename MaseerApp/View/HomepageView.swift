//
//  HomepageView.swift
//  MaseerApp
//
//  Created by Bushra Hatim Alhejaili on 01/12/2025.
//

import SwiftUI

struct HomepageView: View {

    var buttonWidth: CGFloat = 358
    var buttonHeight: CGFloat = 48

    // Callbacks for navigation (RootView decides where to go)
    let onStart: () -> Void
    let onShowHistory: () -> Void

    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 7) {
                    Text("مَسير")
                        .font(.custom("Geeza Pro", size: 36))
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                        .padding(7)

                    Text("انت تعرف وِجهتك..ومَسير يعرف ملامحها")
                        .font(.custom("Geeza Pro", size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                }
                .multilineTextAlignment(.center)

                Spacer()

                VStack(spacing: 19) {
                    Button(action: {
                        onStart()
                    }) {
                        Text("ابدا")
                            .font(.custom("Geeza Pro", size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(.button)
                    )

                    Button(action: {
                        onShowHistory()
                    }) {
                        Text("السّجلات السابقة")
                            .font(.custom("Geeza Pro", size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(.darkishGrey)
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    HomepageView(
        onStart: {},
        onShowHistory: {}
    )
}
