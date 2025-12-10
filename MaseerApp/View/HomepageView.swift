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
                .accessibilityHidden(true)

            VStack {

                Spacer()

                VStack(spacing: 7) {
                    Text("Masser")
                        .font(.custom("Geeza Pro", size: 36))
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                        .padding(7)

                    Text("You know your destination...and the path knows its features")
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
                        Text("Start")
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
                    .accessibilityLabel("Start")
                    .accessibilityHint("Start locaitng tracking and open camera")

                    Button(action: {
                        onShowHistory()
                    }) {
                        Text("History")
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
                    .accessibilityLabel("History")
                    .accessibilityHint("Show saved history")
                }
                .padding(.bottom, 50)
            }
        }
//        .accessibilityLanguage("ar")
    }
}

#Preview {
    HomepageView(
        onStart: {},
        onShowHistory: {}
    )
}
