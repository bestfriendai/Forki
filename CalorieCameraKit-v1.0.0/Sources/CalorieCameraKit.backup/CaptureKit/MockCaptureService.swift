import Foundation

/// Mock capture service for testing
public final class MockCaptureService: FrameCaptureService {
    public var shouldFail = false
    public var mockFrame: CapturedFrame?
    
    public init() {}
    
    public func isCameraAvailable() -> Bool { true }
    
    public func requestPermissions() async throws {
        if shouldFail {
            throw CalorieCameraError.permissionDenied
        }
    }
    
    public func startSession() async throws {
        if shouldFail {
            throw CalorieCameraError.cameraUnavailable
        }
    }
    
    public func stopSession() {}
    
    public func captureFrame() async throws -> CapturedFrame {
        if shouldFail {
            throw CalorieCameraError.captureFailure("Mock failure")
        }
        return mockFrame ?? CapturedFrame(
            rgbImage: Data(),
            depthData: nil,
            cameraIntrinsics: nil
        )
    }
}

