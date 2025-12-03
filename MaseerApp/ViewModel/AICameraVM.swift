//
//  AICameraVM.swift
//  MaseerApp
//  Created by Ghadeer Fallatah on 12/06/1447 AH.
//

import Foundation
import AVFoundation
import Combine

final class AICameraVM: NSObject, ObservableObject {

    // The AVCaptureSession that powers the camera preview.
    @Published var session = AVCaptureSession()

    // If the user denied camera permission, we show a warning.
    @Published var permissionDenied = false

    // MARK: - Request permission + configure camera
    func configure() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            // Already allowed → proceed directly.
            setupSession()

        case .notDetermined:
            // First launch → show system popup.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    } else {
                        self.permissionDenied = true
                    }
                }
            }

        default:
            // .denied or .restricted
            permissionDenied = true
        }
    }

    // MARK: - Stop camera when leaving the screen
    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    // MARK: - Set up the camera session
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // 1. Choose the back camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            print("❌ No back camera found")
            session.commitConfiguration()
            return
        }

        // 2. Create input
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Cannot add camera input")
            session.commitConfiguration()
            return
        }

        // Prevent duplicating inputs
        if session.inputs.isEmpty {
            session.addInput(input)
        }

        session.commitConfiguration()

        // 3. Start the session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
}
