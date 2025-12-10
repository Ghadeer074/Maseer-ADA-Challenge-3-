//
//  loadingScreen.swift
//  locationservice
//
//  Created by Asma Khan on 30/11/2025.
//
import SwiftUI
import CoreLocation
import UIKit

struct LoadingLocationView: View {

    // Our observable location helper.
    @StateObject private var locationManager = LocationManager()
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    // Callback when location is ready
    let onLocated: (CLLocation?) -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack {
                Spacer()

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.6)
                    .accessibilityLabel("Loading your location")

                Text("Locating your location")
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                    .accessibilityLabel("Locating your location")
                    .accessibilityAddTraits(.isHeader)

                if let error = locationManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .accessibilityIdentifier("location_error_message")
                }

                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            locationManager.start()
            if voiceOverEnabled {
                Accessibility.announce("Locating your position")
            }
        }
        .onChange(of: locationManager.currentLocation) {
            // As soon as we have a location, notify parent (RootView)
            if let newLocation = locationManager.currentLocation {
                onLocated(newLocation)
                if voiceOverEnabled {
                    Accessibility.announce("Location found")
                }
            }
        }
        .onChange(of: locationManager.errorMessage) {
            if voiceOverEnabled, let message = locationManager.errorMessage {
                Accessibility.announce(message)
            }
        }
    }
}

#Preview {
    LoadingLocationView { _ in }
}
