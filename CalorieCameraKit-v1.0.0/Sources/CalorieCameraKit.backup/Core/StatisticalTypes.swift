import Foundation

// MARK: - Statistical Foundation

/// Statistical prior with mean and standard deviation
public struct PriorStats: Sendable, Codable, Equatable {
    public let mu: Double     // mean
    public let sigma: Double  // standard deviation

    public init(mu: Double, sigma: Double) {
        self.mu = mu
        self.sigma = sigma
    }

    /// Relative uncertainty (coefficient of variation)
    public var relativeUncertainty: Double {
        guard mu != 0 else { return .infinity }
        return sigma / abs(mu)
    }
}

/// Food priors for Bayesian estimation
public struct FoodPriors: Sendable, Codable, Equatable {
    public let density: PriorStats      // g/ml (e.g., rice: 0.85 ± 0.10)
    public let kcalPerG: PriorStats     // kcal/g (e.g., rice: 1.30 ± 0.05)

    public init(density: PriorStats, kcalPerG: PriorStats) {
        self.density = density
        self.kcalPerG = kcalPerG
    }
}

/// Volume estimate with uncertainty
public struct VolumeEstimate: Sendable, Equatable {
    public let muML: Double      // mean volume in milliliters
    public let sigmaML: Double   // standard deviation

    public init(muML: Double, sigmaML: Double) {
        self.muML = muML
        self.sigmaML = sigmaML
    }

    public var relativeUncertainty: Double {
        guard muML != 0 else { return .infinity }
        return sigmaML / abs(muML)
    }
}

// MARK: - Results

/// Single food item estimate with evidence
public struct ItemEstimate: Sendable, Identifiable {
    public let id: UUID
    public let label: String
    public let volumeML: Double
    public let calories: Double
    public let sigma: Double
    public let evidence: [String]  // Explainable AI: what went into this estimate
    public let densityGPerML: Double?
    public let macrosPer100g: MacronutrientsPer100g?

    public init(
        id: UUID = UUID(),
        label: String,
        volumeML: Double,
        calories: Double,
        sigma: Double,
        evidence: [String],
        densityGPerML: Double? = nil,
        macrosPer100g: MacronutrientsPer100g? = nil
    ) {
        self.id = id
        self.label = label
        self.volumeML = volumeML
        self.calories = calories
        self.sigma = sigma
        self.evidence = evidence
        self.densityGPerML = densityGPerML
        self.macrosPer100g = macrosPer100g
    }

    /// 95% confidence interval (±2σ)
    public var confidenceInterval: (lower: Double, upper: Double) {
        return (calories - 2 * sigma, calories + 2 * sigma)
    }
}

/// Complete calorie result for a plate/meal
public struct CalorieResult: Sendable {
    public let items: [ItemEstimate]
    public let total: (mu: Double, sigma: Double)
    public let timestamp: Date

    public init(
        items: [ItemEstimate],
        total: (mu: Double, sigma: Double),
        timestamp: Date = Date()
    ) {
        self.items = items
        self.total = total
        self.timestamp = timestamp
    }

    /// Relative uncertainty of total
    public var totalRelativeUncertainty: Double {
        guard total.mu != 0 else { return .infinity }
        return total.sigma / abs(total.mu)
    }

    /// 95% confidence interval for total
    public var totalConfidenceInterval: (lower: Double, upper: Double) {
        return (total.mu - 2 * total.sigma, total.mu + 2 * total.sigma)
    }
}

/// Macronutrients per 100g
public struct MacronutrientsPer100g: Sendable, Codable {
    public let proteinG: Double
    public let carbsG: Double
    public let fatG: Double

    public init(proteinG: Double, carbsG: Double, fatG: Double) {
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
    }
}

// MARK: - Configuration

/// Main configuration for calorie camera
public struct CalorieConfig: Sendable, Codable {
    /// Target relative uncertainty (σ/μ) to achieve
    public let targetRelSigma: Double

    /// Threshold for asking binary questions (VoI)
    public let voiThreshold: Double

    /// Feature flags
    public let flags: FeatureFlags

    /// Router weights for source selection
    public let routerWeights: RouterWeights

    /// Penalty for correlated sources (default 1.0 = no penalty)
    public let correlationPenalty: Double

    /// Pool of binary questions to ask when uncertainty high
    public let askBinaryPool: [String]
    
    /// Parameters used by the capture quality estimator
    public let captureQuality: CaptureQualityParameters

    public init(
        targetRelSigma: Double = 0.15,
        voiThreshold: Double = 0.27,
        flags: FeatureFlags = FeatureFlags(),
        routerWeights: RouterWeights = RouterWeights(),
        correlationPenalty: Double = 1.0,
        askBinaryPool: [String] = [],
        captureQuality: CaptureQualityParameters = CaptureQualityParameters()
    ) {
        self.targetRelSigma = targetRelSigma
        self.voiThreshold = voiThreshold
        self.flags = flags
        self.routerWeights = routerWeights
        self.correlationPenalty = correlationPenalty
        self.askBinaryPool = askBinaryPool
        self.captureQuality = captureQuality
    }

    /// Default safe configuration
    public static let `default` = CalorieConfig()

    /// Development configuration
    public static let development = CalorieConfig(
        targetRelSigma: 0.20,
        voiThreshold: 0.30,
        flags: FeatureFlags(
            routerEnabled: true,
            voiEnabled: true,
            mixtureEnabled: false
        ),
        routerWeights: RouterWeights(
            label: 0.6,
            menu: 0.5,
            geo: 0.7
        ),
        correlationPenalty: 1.2,
        askBinaryPool: ["creamBase", "clearBroth", "friedOilTsp"],
        captureQuality: CaptureQualityParameters(
            parallaxTarget: 0.28,
            depthCoverageTarget: 0.65,
            parallaxWeight: 0.4,
            depthWeight: 0.35,
            trackingWeight: 0.25,
            minimumStableFrames: 3,
            stopThreshold: 0.82
        )
    )
}

/// Feature flags for enabling/disabling subsystems
public struct FeatureFlags: Sendable, Codable {
    public let routerEnabled: Bool
    public let voiEnabled: Bool
    public let mixtureEnabled: Bool

    public init(
        routerEnabled: Bool = false,
        voiEnabled: Bool = false,
        mixtureEnabled: Bool = false
    ) {
        self.routerEnabled = routerEnabled
        self.voiEnabled = voiEnabled
        self.mixtureEnabled = mixtureEnabled
    }
}

/// Router weights for combining different sources
public struct RouterWeights: Sendable, Codable {
    public let label: Double
    public let menu: Double
    public let geo: Double

    public init(label: Double = 0.6, menu: Double = 0.5, geo: Double = 0.7) {
        self.label = label
        self.menu = menu
        self.geo = geo
    }
}

/// Parameters controlling capture quality gating
public struct CaptureQualityParameters: Sendable, Codable {
    public let parallaxTarget: Double      // metres
    public let depthCoverageTarget: Double // fraction 0-1
    public let parallaxWeight: Double
    public let depthWeight: Double
    public let trackingWeight: Double
    public let minimumStableFrames: Int
    public let stopThreshold: Double       // 0-1

    public init(
        parallaxTarget: Double = 0.25,
        depthCoverageTarget: Double = 0.60,
        parallaxWeight: Double = 0.4,
        depthWeight: Double = 0.35,
        trackingWeight: Double = 0.25,
        minimumStableFrames: Int = 3,
        stopThreshold: Double = 0.8
    ) {
        self.parallaxTarget = max(parallaxTarget, 0.01)
        self.depthCoverageTarget = min(max(depthCoverageTarget, 0.01), 1.0)
        self.parallaxWeight = max(parallaxWeight, 0.0)
        self.depthWeight = max(depthWeight, 0.0)
        self.trackingWeight = max(trackingWeight, 0.0)
        self.minimumStableFrames = max(minimumStableFrames, 0)
        self.stopThreshold = min(max(stopThreshold, 0.0), 1.0)
    }
}

// MARK: - Geometry Estimate

/// Geometry-based calorie estimate
public struct GeometryEstimate: Sendable {
    public let label: String
    public let volumeML: Double
    public let calories: Double
    public let sigma: Double
    public let evidence: [String]

    public init(
        label: String,
        volumeML: Double,
        calories: Double,
        sigma: Double,
        evidence: [String]
    ) {
        self.label = label
        self.volumeML = volumeML
        self.calories = calories
        self.sigma = sigma
        self.evidence = evidence
    }
}

// MARK: - Tracking & Quality

/// Simplified tracking state extracted from ARKit/Vision
public enum TrackingState: String, Sendable, Codable {
    case notAvailable
    case limited
    case normal

    /// Numeric quality contribution (0-1) for weighting
    public var qualityScore: Double {
        switch self {
        case .normal:
            return 1.0
        case .limited:
            return 0.6
        case .notAvailable:
            return 0.0
        }
    }

    /// True when tracking is stable enough to accumulate frames
    public var isStable: Bool {
        self == .normal
    }
}

/// Per-frame metrics used by the capture quality estimator
public struct CaptureQualitySample: Sendable {
    public let timestamp: Date
    /// Total parallax travelled since capture start (metres)
    public let parallax: Double
    /// Current AR tracking state
    public let trackingState: TrackingState
    /// Fraction (0-1) of pixels with reliable depth
    public let depthCoverage: Double

    public init(
        timestamp: Date = Date(),
        parallax: Double,
        trackingState: TrackingState,
        depthCoverage: Double
    ) {
        self.timestamp = timestamp
        self.parallax = parallax
        self.trackingState = trackingState
        self.depthCoverage = depthCoverage
    }
}

/// Result of evaluating the capture quality gates
public struct CaptureQualityStatus: Sendable {
    /// Weighted quality score, 0-1
    public let score: Double
    /// Score relative to stop threshold (0-1)
    public let progress: Double
    /// Whether the estimator recommends stopping capture
    public let shouldStop: Bool
    /// True when parallax requirement is satisfied
    public let meetsParallax: Bool
    /// True when depth coverage requirement is satisfied
    public let meetsDepth: Bool
    /// True when tracking has been stable long enough
    public let meetsTracking: Bool

    public init(
        score: Double,
        progress: Double,
        shouldStop: Bool,
        meetsParallax: Bool,
        meetsDepth: Bool,
        meetsTracking: Bool
    ) {
        self.score = score
        self.progress = progress
        self.shouldStop = shouldStop
        self.meetsParallax = meetsParallax
        self.meetsDepth = meetsDepth
        self.meetsTracking = meetsTracking
    }
}

