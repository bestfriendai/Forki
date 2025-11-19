import Foundation

/// Simple fusion engine for combining estimates
public final class FusionEngine {
    public struct Config: Sendable {
        public let defaultWeight: Double
        
        public init(defaultWeight: Double = 0.5) {
            self.defaultWeight = defaultWeight
        }
        
        public static let `default` = Config()
    }
    
    private let config: Config
    
    public init(config: Config = .default) {
        self.config = config
    }
    
    /// Fuse multiple estimates (placeholder implementation)
    public func fuse(estimates: [Double], weights: [Double]? = nil) -> (mu: Double, sigma: Double) {
        guard !estimates.isEmpty else {
            return (mu: 0, sigma: 100)
        }
        
        let w = weights ?? Array(repeating: config.defaultWeight, count: estimates.count)
        let totalWeight = w.reduce(0, +)
        guard totalWeight > 0 else {
            return (mu: estimates.first ?? 0, sigma: 100)
        }
        
        let weightedSum = zip(estimates, w).map(*).reduce(0, +)
        let mu = weightedSum / totalWeight
        
        // Simple uncertainty estimate
        let variance = estimates.map { pow($0 - mu, 2) }.reduce(0, +) / Double(estimates.count)
        let sigma = sqrt(variance)
        
        return (mu: mu, sigma: max(sigma, 50))
    }
    
    /// Calculate calories from geometry using delta method for uncertainty propagation
    /// Formula: C = V × ρ × e
    /// Where: V = volume (mL), ρ = density (g/mL), e = energy density (kcal/g)
    public func caloriesFromGeometry(volume: VolumeEstimate, priors: FoodPriors) -> (mu: Double, sigma: Double) {
        // Convert volume from mL to L for calculation
        let volumeL = volume.muML / 1000.0
        let volumeSigmaL = volume.sigmaML / 1000.0
        
        // Mean calories: C = V × ρ × e
        let mu = volumeL * priors.density.mu * priors.kcalPerG.mu
        
        // Delta method for uncertainty propagation:
        // σ_C² = (∂C/∂V)²σ_V² + (∂C/∂ρ)²σ_ρ² + (∂C/∂e)²σ_e²
        // Where:
        // ∂C/∂V = ρ × e
        // ∂C/∂ρ = V × e
        // ∂C/∂e = V × ρ
        
        let dCdV = priors.density.mu * priors.kcalPerG.mu
        let dCdrho = volumeL * priors.kcalPerG.mu
        let dCde = volumeL * priors.density.mu
        
        let variance = pow(dCdV * volumeSigmaL, 2) +
                      pow(dCdrho * priors.density.sigma, 2) +
                      pow(dCde * priors.kcalPerG.sigma, 2)
        
        let sigma = sqrt(variance)
        
        return (mu: mu, sigma: max(sigma, 10.0)) // Minimum 10 kcal uncertainty
    }
}

