//
//  AICameraView.swift
//  MaseerApp
//  Created by Asma Khan on 30/11/2025.
//

import SwiftUI
import CoreLocation
import AVFoundation

// MARK: - Camera preview wrapper

/// UIView whose main layer *is* an AVCaptureVideoPreviewLayer.
final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        setPreviewRotation(for: view.videoPreviewLayer)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        setPreviewRotation(for: uiView.videoPreviewLayer)
    }

    private func setPreviewRotation(for layer: AVCaptureVideoPreviewLayer) {
        if #available(iOS 17.0, *) {
            if let connection = layer.connection,
               connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 0
            }
        } else {
            if let connection = layer.connection,
               connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
    }
}

// MARK: - Main AI camera screen
struct AICamView: View {
    @Environment(\.dismiss) private var dismiss

    // Accept the user's (optional) location passed from the loading screen.
    let userLocation: CLLocation?

    // Our camera ViewModel (AVCaptureSession + Vision logic)
    @StateObject private var cameraVM = AICameraVM()

    // Simple TTS for spoken feedback
    @State private var speechSynth = AVSpeechSynthesizer()
    @State private var lastSpokenText: String = ""
    @State private var lastSpokenTime: Date = .distantPast

    var body: some View {
        ZStack {

            // LIVE CAMERA BACKGROUND
            CameraPreview(session: cameraVM.session)
                .ignoresSafeArea()

            // CLOSE BUTTON
            VStack {
                HStack {
                    Spacer()

                    Text("إغلاق")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(
                            BlurView(style: .systemThinMaterialDark)
                                .opacity(0.85)
                        )
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                        .onTapGesture {
                            dismiss()
                        }
                }
                .padding(.top, 45)
                .padding(.trailing, 25)

                Spacer()
            }

            // BOTTOM GLASS SHEET
            VStack {
                Spacer()

                ZStack {
                    BlurView(style: .systemUltraThinMaterialDark)
                        .opacity(0.90)
                    Color.black.opacity(0.25)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 360)
                .clipShape(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                )
                .overlay(
                    VStack(alignment: .trailing, spacing: 14) {
                        Text("جاري إنتاج معلومات محيطك..")
                            .foregroundColor(.white)
                            .font(.headline)

                        // 👇 AI-generated description text
                        Text(cameraVM.descriptionText)
                            .foregroundColor(.white)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if cameraVM.permissionDenied {
                            Text("الرجاء تفعيل صلاحية الكاميرا من الإعدادات.")
                                .foregroundColor(.red)
                        }

                        if let loc = userLocation {
                            Text("Lat: \(loc.coordinate.latitude)")
                                .foregroundColor(.white)
                            Text("Lon: \(loc.coordinate.longitude)")
                                .foregroundColor(.white)
                        } else {
                            Text("No location yet.")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(25)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear { cameraVM.configure() }
        .onDisappear {
            cameraVM.stop()
            speechSynth.stopSpeaking(at: .immediate)
        }
        .onChange(of: cameraVM.descriptionText) { oldValue, newValue in
            speak(text: newValue)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Simple Arabic TTS
    private func speak(text: String) {
        // Don’t speak empty stuff
        guard !text.isEmpty else { return }

        // Don’t repeat the exact same sentence
        guard text != lastSpokenText else { return }

        // Don’t speak more often than every 2 seconds
        let now = Date()
        guard now.timeIntervalSince(lastSpokenTime) > 2 else { return }
        lastSpokenTime = now
        lastSpokenText = text

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        utterance.rate = 0.48   // tweak if you want slower/faster

        speechSynth.stopSpeaking(at: .immediate)
        speechSynth.speak(utterance)
    }

}

// Your existing blur helper
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    AICamView(userLocation: nil)
}
