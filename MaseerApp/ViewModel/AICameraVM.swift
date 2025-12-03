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
    @Published var descriptionText: String = "جاري تحليل المشهد أمامك..."

    // Internal queues / flags
    private let sessionQueue = DispatchQueue(label: "AICameraSessionQueue")
    private var isProcessingFrame = false
    private var lastVisionTime: CFTimeInterval = 0
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
                        self.descriptionText = "صلاحية الكاميرا مرفوضة."
                    }
                }
            }

        default:
            permissionDenied = true
            descriptionText = "صلاحية الكاميرا مرفوضة. فعّلها من الإعدادات."
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
                self.descriptionText = "لا يمكن الوصول للكاميرا الخلفية."
            }
            return
        }

        // 2. Input
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Cannot add camera input")
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.descriptionText = "تعذّر إعداد الكاميرا."
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
                // 90 degrees typically corresponds to portrait
                let portraitAngle: CGFloat = 90
                if connection.isVideoRotationAngleSupported(portraitAngle) {
                    connection.videoRotationAngle = portraitAngle
                } else if connection.isVideoRotationAngleSupported(0) {
                    // Fallback to 0 if 90 not supported
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
        defer { /* reset in completion handler */ }

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
                return (text, obs.boundingBox)   // boundingBox is in normalized coords (0..1)
            }
            .max { a, b in
                let areaA = a.1.width * a.1.height
                let areaB = b.1.width * b.1.height
                return areaA < areaB
            }

            guard let (text, box) = best, !text.isEmpty else { return }

            // Compute rough left/center/right based on horizontal position
            let midX = box.midX
            let position: String
            if midX < 0.33 {
                position = "إلى يسارك"
            } else if midX > 0.66 {
                position = "إلى يمينك"
            } else {
                position = "أمامك"
            }

            // Compute coarse distance based on area (very rough)
            let area = box.width * box.height
            let distance: String
            if area > 0.10 {
                distance = "على بُعد خطوة أو خطوتين تقريبًا"
            } else if area > 0.03 {
                distance = "على بُعد بضع خطوات"
            } else {
                distance = "على مسافة أبعد قليلًا"
            }

            let newDescription = "\(position) \(distance) لافتة مكتوب عليها: \"\(text)\""

            DispatchQueue.main.async {
                // Only update if it's really different, to reduce spam
                if newDescription != self.descriptionText {
                    self.descriptionText = newDescription
                }
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ar", "en"]

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
