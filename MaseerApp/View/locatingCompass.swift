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

    // Callback when location is ready
    let onLocated: (CLLocation?) -> Void

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
            locationManager.start()
        }
        .onChange(of: locationManager.currentLocation) {
            // As soon as we have a location, notify parent (RootView)
            if let newLocation = locationManager.currentLocation {
                onLocated(newLocation)
            }
        }
    }
}

#Preview {
    LoadingLocationView { _ in }
}
