import Foundation
import CoreGraphics
import simd

// MARK: - Core Domain Types

/// Represents captured frame data with depth information
public struct CapturedFrame: Sendable {
    public let id: UUID
    public let timestamp: Date
    public let rgbImage: Data // JPEG or PNG data
    public let depthData: DepthData?
    public let cameraIntrinsics: CameraIntrinsics?
    public let metadata: FrameMetadata

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        rgbImage: Data,
        depthData: DepthData? = nil,
        cameraIntrinsics: CameraIntrinsics? = nil,
        metadata: FrameMetadata = FrameMetadata()
    ) {
        self.id = id
        self.timestamp = timestamp
        self.rgbImage = rgbImage
        self.depthData = depthData
        self.cameraIntrinsics = cameraIntrinsics
        self.metadata = metadata
    }
}

/// Depth information from LiDAR or SfM
public struct DepthData: Sendable {
    public let width: Int
    public let height: Int
    public let depthMap: [Float] // in meters
    public let confidenceMap: [Float]? // 0-1
    public let source: DepthSource

    public init(width: Int, height: Int, depthMap: [Float], confidenceMap: [Float]? = nil, source: DepthSource) {
        self.width = width
        self.height = height
        self.depthMap = depthMap
        self.confidenceMap = confidenceMap
        self.source = source
    }
}

public enum DepthSource: String, Sendable, Codable {
    case lidar
    case structureFromMotion
    case stereo
    case monocular
}

/// Camera intrinsic parameters
public struct CameraIntrinsics: Sendable {
    public let focalLength: SIMD2<Float> // fx, fy
    public let principalPoint: SIMD2<Float> // cx, cy
    public let imageSize: SIMD2<Int> // width, height

    public init(focalLength: SIMD2<Float>, principalPoint: SIMD2<Float>, imageSize: SIMD2<Int>) {
        self.focalLength = focalLength
        self.principalPoint = principalPoint
        self.imageSize = imageSize
    }
}

/// Frame capture metadata
public struct FrameMetadata: Sendable {
    public let exposureDuration: TimeInterval?
    public let iso: Float?
    public let brightness: Float?
    public let deviceOrientation: DeviceOrientation

    public init(
        exposureDuration: TimeInterval? = nil,
        iso: Float? = nil,
        brightness: Float? = nil,
        deviceOrientation: DeviceOrientation = .portrait
    ) {
        self.exposureDuration = exposureDuration
        self.iso = iso
        self.brightness = brightness
        self.deviceOrientation = deviceOrientation
    }
}

public enum DeviceOrientation: String, Sendable, Codable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case unknown
}

// MARK: - Errors

public enum CalorieCameraError: LocalizedError, Sendable {
    case cameraUnavailable
    case permissionDenied
    case depthUnavailable
    case captureFailure(String)
    case detectionFailure(String)
    case networkFailure(String)
    case configurationError(String)
    case processingFailed(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera is not available on this device"
        case .permissionDenied:
            return "Camera permission denied"
        case .depthUnavailable:
            return "Depth sensing unavailable (requires LiDAR or multi-frame)"
        case .captureFailure(let msg):
            return "Capture failed: \(msg)"
        case .detectionFailure(let msg):
            return "Detection failed: \(msg)"
        case .networkFailure(let msg):
            return "Network error: \(msg)"
        case .configurationError(let msg):
            return "Configuration error: \(msg)"
        case .processingFailed(let msg):
            return "Processing failed: \(msg)"
        case .unknown(let msg):
            return "Unknown error: \(msg)"
        }
    }
}

