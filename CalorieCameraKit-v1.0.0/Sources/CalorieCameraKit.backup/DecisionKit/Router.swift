import Foundation

/// Router for deciding which analysis path to use
public final class AnalyzerRouter {
    private let config: CalorieConfig
    
    public init(config: CalorieConfig) {
        self.config = config
    }
    
    /// Fuse geometry and analyzer observations
    public func fuse(
        geometry: GeometryEstimate,
        analyzerObservation: AnalyzerObservation?
    ) -> (fusedCalories: Double, fusedSigma: Double, evidence: [String]) {
        var evidence = geometry.evidence
        
        if let analyzer = analyzerObservation {
            evidence.append(contentsOf: analyzer.evidence)
            
            // If analyzer provides calories, use weighted fusion
            if let analyzerCalories = analyzer.calories {
                let analyzerSigma = analyzer.sigmaCalories ?? analyzerCalories * 0.2
                
                // Weighted average: prefer analyzer if available
                let analyzerWeight = 0.7
                let geometryWeight = 0.3
                
                let fused = (analyzerCalories * analyzerWeight) + (geometry.calories * geometryWeight)
                let fusedSigma = sqrt(pow(analyzerSigma * analyzerWeight, 2) + pow(geometry.sigma * geometryWeight, 2))
                
                return (fusedCalories: fused, fusedSigma: fusedSigma, evidence: evidence)
            }
        }
        
        // Fallback to geometry only
        return (fusedCalories: geometry.calories, fusedSigma: geometry.sigma, evidence: evidence)
    }
}

/// Analyzer observation from API
public struct AnalyzerObservation: Sendable {
    public let label: String
    public let confidence: Double
    public let priors: FoodPriors?
    public let evidence: [String]
    public let path: DetectionPath?
    public let calories: Double?
    public let sigmaCalories: Double?
    
    public init(
        label: String,
        confidence: Double,
        priors: FoodPriors?,
        evidence: [String],
        path: DetectionPath? = nil,
        calories: Double? = nil,
        sigmaCalories: Double? = nil
    ) {
        self.label = label
        self.confidence = confidence
        self.priors = priors
        self.evidence = evidence
        self.path = path
        self.calories = calories
        self.sigmaCalories = sigmaCalories
    }
}

public enum DetectionPath: String, Sendable {
    case label
    case menu
    case geometry
}

