//
//  loadingScreen.swift
//  locationservice
//
//  Created by Asma Khan on 30/11/2025.
//

import SwiftUI
import CoreLocation

struct LoadingLocationView: View {

    // Our observable location helper.
    @StateObject private var locationManager = LocationManager()

    // When true, we move to the camera + AI screen.
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

                // Optional: show an error if permission is denied, etc.
                if let error = locationManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            // Start requesting the location as soon as this view shows.
            locationManager.start()
        }
        .onChange(of: locationManager.currentLocation) { oldLocation, newLocation in
            // When currentLocation becomes non-nil => we have a fix.
            if newLocation != nil {
                goNext = true
            }
        }
        .fullScreenCover(isPresented: $goNext) {
            // Pass the location forward to the camera screen.
            CamView(userLocation: locationManager.currentLocation)
        }
    }
}

#Preview {
    LoadingLocationView()
}
