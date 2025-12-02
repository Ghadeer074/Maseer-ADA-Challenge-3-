
//
//  loadingScreen.swift
//  locationservice
//
//  Created by Asma Khan on 30/11/2025.
//

import SwiftUI

struct LoadingLocationView: View {
    @State private var goNext = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.6)
               
                Text("يتم تحديد موقعك")
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                goNext = true
            }
        }
        .fullScreenCover(isPresented: $goNext) {
            SurroundingsMainScreen()
        }
    }
}

#Preview {
    LoadingLocationView()
}

