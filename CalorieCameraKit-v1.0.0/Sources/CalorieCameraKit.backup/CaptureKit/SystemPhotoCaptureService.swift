#if canImport(AVFoundation) && canImport(UIKit)
import AVFoundation
import UIKit
import Foundation

/// System photo capture service using UIImagePickerController
public final class SystemPhotoCaptureService: NSObject, FrameCaptureService, CameraPreviewProviding {
    private var captureSession: AVCaptureSession?
    public var previewSession: AVCaptureSession? { captureSession }
    
    public func isCameraAvailable() -> Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    public func requestPermissions() async throws {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        guard status else {
            throw CalorieCameraError.permissionDenied
        }
    }
    
    public func startSession() async throws {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            throw CalorieCameraError.cameraUnavailable
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        captureSession = session
        session.startRunning()
    }
    
    public func stopSession() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    public func captureFrame() async throws -> CapturedFrame {
        // For now, return a placeholder frame
        // In a real implementation, this would capture from the session
        return CapturedFrame(
            rgbImage: Data(),
            depthData: nil,
            cameraIntrinsics: nil
        )
    }
}
#endif

