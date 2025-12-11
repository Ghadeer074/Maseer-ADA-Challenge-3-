//
//  AICameraView.swift
//  MaseerApp
//  Created by Asma Khan on 30/11/2025.
//

import SwiftUI
import CoreLocation
import AVFoundation

// MARK: - Camera preview wrapper

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

    // Accept the user's (optional) location passed from the loading screen.
    let userLocation: CLLocation?

    // When user finishes (taps close), we pass the last description up
    let onFinish: (String) -> Void

    @StateObject private var cameraVM = AICameraVM()

    var body: some View {
        ZStack {

            CameraPreview(session: cameraVM.session)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // CLOSE BUTTON
            VStack {
                HStack {
                    Spacer()

                    Button {
                        onFinish(cameraVM.descriptionText)
                    } label: {
                        Text("Close")
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
                    }
                    .accessibilityLabel("Close")
                    .accessibilityHint("Close camera")
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
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity)
                .frame(height: 360)
                .clipShape(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                )
                .overlay(
                    VStack(alignment: .trailing, spacing: 14) {
                        Text("Genrating information about your surroundings ...")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text(cameraVM.descriptionText)
                            .foregroundColor(.white)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if cameraVM.permissionDenied {
                            Text("Please enable camera access from settings.")
                                .foregroundColor(.red)
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
        }
        .environment(\.layoutDirection, .rightToLeft)
//        .accessibilityLanguage("ar")
    }
}

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
    AICamView(userLocation: nil) { _ in }
}
