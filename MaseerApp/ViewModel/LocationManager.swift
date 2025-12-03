//
//  tempModel.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 09/06/1447 AH.
//

import Foundation
import CoreLocation
import Combine

// Simple, observable wrapper around CLLocationManager.
// SwiftUI can watch this and react when the location changes.
final class LocationManager: NSObject, ObservableObject {

    // Last location got from iOS (nil at the start).
    @Published var currentLocation: CLLocation?

    // Are we currently trying to get a location?
    @Published var isLocating: Bool = false

    // Any error message to show (e.g. permission denied).
    @Published var errorMessage: String?

    // The underlying Apple location manager.
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self                 // send callbacks here
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // Start asking the system for the user's location.
    func start() {
        errorMessage = nil
        isLocating = true

        switch manager.authorizationStatus {
        case .notDetermined:
            // First time: show the system popup.
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            //  already have permission.
            manager.startUpdatingLocation()

        case .denied, .restricted:
            // User said "no" or cannot give permission.
            isLocating = false
            errorMessage = "لا يمكن استخدام موقعك. تأكد من تفعيل الصلاحيات في الإعدادات."

        @unknown default:
            isLocating = false
        }
    }
}

// CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    // Called when the user changes the permission (e.g. taps "Allow").
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    // Called whenever we get new GPS coordinates.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }

        currentLocation = last      // publish to SwiftUI
        isLocating = false
        manager.stopUpdatingLocation() // for now we just need 1 fix
    }

    // Called when something goes wrong (no GPS, etc.).
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocating = false
        errorMessage = error.localizedDescription
    }
}
