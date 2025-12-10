//
//  AICameraVM.swift
//  MaseerApp
//  Created by Ghadeer Fallatah on 12/06/1447 AH.
//
//

import Foundation
import AVFoundation
import Combine
import Vision

final class AICameraVM: NSObject, ObservableObject {

    // Camera session for the preview
    @Published var session = AVCaptureSession()

    // If user denied camera permission
    @Published var permissionDenied = false

    // Text that we show (and speak) about surroundings
    @Published var descriptionText: String = "Analyzing your surroundings..."

    // Internal queues / flags
    private let sessionQueue = DispatchQueue(label: "AICameraSessionQueue")
    private var isProcessingFrame = false
    private var lastVisionTime: CFTimeInterval = 0

    // Last recognized sign text to avoid repeating the same thing
    private var lastRecognizedText: String = ""
}

// MARK: - Public API
extension AICameraVM {

    func configure() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            setupSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    } else {
                        self.permissionDenied = true
                        self.descriptionText = "Camera permission denied."
                    }
                }
            }

        default:
            permissionDenied = true
            descriptionText = "Camera permission denied. Enable it from settings."
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

// MARK: - Session setup
extension AICameraVM {

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // 1. Back camera
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("❌ No back camera found")
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.descriptionText = "Cannot access back camera"
            }
            return
        }

        // 2. Input
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Cannot add camera input")
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.descriptionText = "Connot use camera"
            }
            return
        }

        if session.inputs.isEmpty {
            session.addInput(input)
        }

        // 3. Video output (frames for Vision)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: sessionQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        if let connection = output.connection(with: .video) {
            if #available(iOS 17.0, *) {
                // 0 degrees = portrait
                if connection.isVideoRotationAngleSupported(0) {
                    connection.videoRotationAngle = 0
                }
            } else {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
        }

        session.commitConfiguration()

        // 4. Start session on background queue
        sessionQueue.async {
            self.session.startRunning()
        }
    }
}

// MARK: - Capture output delegate (Vision)
extension AICameraVM: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        // Throttle: only run Vision ~once every 1.5 seconds
        let now = CACurrentMediaTime()
        guard now - lastVisionTime > 1.5 else { return }
        lastVisionTime = now

        guard !isProcessingFrame else { return }
        isProcessingFrame = true

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            isProcessingFrame = false
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            self.isProcessingFrame = false

            if let error = error {
                print("Vision error: \(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation],
                  !observations.isEmpty else {
                // No text in this frame—keep last useful description.
                return
            }

            // Pick the observation with the largest area (most prominent text)
            let best = observations.compactMap { obs -> (String, CGRect)? in
                guard let text = obs.topCandidates(1).first?.string else { return nil }
                return (text, obs.boundingBox)   // boundingBox is normalized (0..1)
            }
            .max { a, b in
                let areaA = a.1.width * a.1.height
                let areaB = b.1.width * b.1.height
                return areaA < areaB
            }

            guard let (text, box) = best, !text.isEmpty else { return }

            // Prevent repeating the exact same recognized text
            if text == self.lastRecognizedText {
                return
            }
            self.lastRecognizedText = text

            // Compute rough left/center/right based on horizontal position
            let midX = box.midX
            let position: String
            if midX < 0.33 {
                position = " To your left"
            } else if midX > 0.66 {
                position = "To your right"
            } else {
                position = "To your front"
            }

            // Compute coarse distance based on area (very rough)
            let area = box.width * box.height
            let distance: String
            if area > 0.10 {
                distance = "Just a step or two away."
            } else if area > 0.03 {
                distance = "Just a few steps away."
            } else {
                distance = "A little further away."
            }

            let newDescription = "\(position) \(distance) A sign that reads: \"\(text)\""

            DispatchQueue.main.async {
                if newDescription != self.descriptionText {
                    self.descriptionText = newDescription
                }
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
//        request.recognitionLanguages = ["ar", "en"]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .up,
                                            options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("Vision handler error: \(error.localizedDescription)")
            isProcessingFrame = false
        }
    }
}
