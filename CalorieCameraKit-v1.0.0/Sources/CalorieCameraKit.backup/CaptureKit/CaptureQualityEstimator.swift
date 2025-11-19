import Foundation

/// Estimates capture quality based on parallax, depth, and tracking
public final class CaptureQualityEstimator {
    private let parameters: CaptureQualityParameters
    private var samples: [CaptureQualitySample] = []
    
    public init(parameters: CaptureQualityParameters) {
        self.parameters = parameters
    }
    
    public func reset() {
        samples.removeAll()
    }
    
    public func evaluate(sample: CaptureQualitySample) -> CaptureQualityStatus {
        samples.append(sample)
        
        // Calculate individual component scores
        let parallaxScore = min(1.0, sample.parallax / parameters.parallaxTarget)
        let depthScore = min(1.0, sample.depthCoverage / parameters.depthCoverageTarget)
        let trackingScore = sample.trackingState.qualityScore
        
        // Count stable frames
        let stableFrames = samples.filter { $0.trackingState.isStable }.count
        let trackingMeets = stableFrames >= parameters.minimumStableFrames
        
        // Weighted overall score
        let overallScore = (
            parallaxScore * parameters.parallaxWeight +
            depthScore * parameters.depthWeight +
            trackingScore * parameters.trackingWeight
        )
        
        let progress = min(1.0, overallScore / parameters.stopThreshold)
        let shouldStop = overallScore >= parameters.stopThreshold &&
                        parallaxScore >= 0.8 &&
                        depthScore >= 0.8 &&
                        trackingMeets
        
        return CaptureQualityStatus(
            score: overallScore,
            progress: progress,
            shouldStop: shouldStop,
            meetsParallax: parallaxScore >= 0.8,
            meetsDepth: depthScore >= 0.8,
            meetsTracking: trackingMeets
        )
    }
}

