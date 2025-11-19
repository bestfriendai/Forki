import Foundation
#if canImport(AVFoundation) && canImport(UIKit)
import AVFoundation
#endif

// MARK: - Pipeline Protocols (Dependency Inversion)

/// Captures frames with optional depth data
public protocol FrameCaptureService: Sendable {
    /// Check if camera is available on this device
    func isCameraAvailable() -> Bool

    /// Request camera permissions
    func requestPermissions() async throws

    /// Start capture session
    func startSession() async throws

    /// Stop capture session
    func stopSession()

    /// Capture a single frame
    func captureFrame() async throws -> CapturedFrame
}

#if canImport(AVFoundation) && canImport(UIKit)
/// Protocol for services that provide a camera preview session
public protocol CameraPreviewProviding {
    var previewSession: AVFoundation.AVCaptureSession? { get }
}
#endif

