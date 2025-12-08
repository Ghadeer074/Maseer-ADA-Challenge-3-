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

// MARK: - Helper: direction + distance from bounding box
extension AICameraVM {

    /// Interprets where the sign is in the frame and roughly how far it seems.
    /// - Parameter box: VNRecognizedTextObservation.boundingBox (normalized 0...1)
    private func makeDirection(from box: CGRect) -> (directionSentence: String, distanceSentence: String) {

        // 1. Horizontal position → left / center / right
        let centerX = box.midX
        let directionSentence: String

        switch centerX {
        case ..<0.35:
            directionSentence = "اللافتة تميل قليلًا إلى يسارك."
        case 0.35...0.65:
            directionSentence = "اللافتة تقريبًا أمامك في المنتصف."
        default:
            directionSentence = "اللافتة تميل قليلًا إلى يمينك."
        }

        // 2. Bounding-box height → rough distance estimate
        let height = box.height
        let distanceSentence: String

        switch height {
        case 0.35...1.0:
            distanceSentence = "هي قريبة جدًا، يمكنك الوصول إليها بخطوات قليلة."
        case 0.18..<0.35:
            distanceSentence = "هي قريبة، تقدَّم عدة خطوات للأمام."
        case 0.08..<0.18:
            distanceSentence = "هي على مسافة متوسطة، تقدَّم للأمام حتى تكبر اللافتة في الصورة."
        default:
            distanceSentence = "هي بعيدة نسبيًا، تقدَّم للأمام حتى تصبح أقرب."
        }

        return (directionSentence, distanceSentence)
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

            // Build dynamic direction + distance sentences
            let (directionSentence, distanceSentence) = self.makeDirection(from: box)

            let newDescription = """
            في المشهد أمامك لافتة مكتوب عليها "\(text)".
            \(directionSentence)
            \(distanceSentence)
            """

            DispatchQueue.main.async {
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
