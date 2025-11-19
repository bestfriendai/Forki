import Foundation

/// Analyzer client protocol
public protocol AnalyzerClient: Sendable {
    func analyze(imageData: Data, mimeType: String) async throws -> AnalyzerObservation
}

/// HTTP-based analyzer client for Supabase Edge Function
public struct HTTPAnalyzerClient: AnalyzerClient {
    public struct Configuration: Sendable {
        public let baseURL: URL
        public let endpointPath: String
        public let timeout: TimeInterval
        public let apiKey: String?

        public init(
            baseURL: URL,
            endpointPath: String = "/analyze_food",
            timeout: TimeInterval = 20.0,
            apiKey: String? = nil
        ) {
            self.baseURL = baseURL
            self.endpointPath = endpointPath
            self.timeout = timeout
            self.apiKey = apiKey
        }
    }

    private let configuration: Configuration
    private let urlSession: URLSession

    public init(
        configuration: Configuration,
        urlSession: URLSession = .shared
    ) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    public func analyze(imageData: Data, mimeType: String) async throws -> AnalyzerObservation {
        var request = URLRequest(
            url: configuration.baseURL.appendingPathComponent(configuration.endpointPath)
        )
        request.httpMethod = "POST"
        request.timeoutInterval = configuration.timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add Supabase API key header if provided
        if let apiKey = configuration.apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let payload = AnalyzerRequestPayload(
            imageBase64: imageData.base64EncodedString(),
            mimeType: mimeType
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await urlSession.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let body = String(data: data, encoding: .utf8) ?? "n/a"
            throw AnalyzerClientError.server(status: status, body: body)
        }

        let decoded: AnalyzerResponsePayload
        do {
            decoded = try JSONDecoder().decode(AnalyzerResponsePayload.self, from: data)
        } catch {
            throw AnalyzerClientError.decoding(error)
        }
        
        guard let firstItem = decoded.items.first else {
            throw AnalyzerClientError.decoding(NSError(domain: "AnalyzerClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No items in response"]))
        }

        // Parse priors from response
        let priors: FoodPriors? = firstItem.priors.map { priorsData in
            FoodPriors(
                density: PriorStats(mu: priorsData.density.mu, sigma: priorsData.density.sigma),
                kcalPerG: PriorStats(mu: priorsData.kcalPerG.mu, sigma: priorsData.kcalPerG.sigma)
            )
        }

        // Parse path from response
        let path: DetectionPath? = firstItem.path.flatMap { DetectionPath(rawValue: $0) }

        return AnalyzerObservation(
            label: firstItem.label,
            confidence: firstItem.confidence,
            priors: priors,
            evidence: firstItem.evidence ?? [],
            path: path,
            calories: firstItem.calories,
            sigmaCalories: firstItem.sigmaCalories
        )
    }
}

public enum AnalyzerClientError: Error, LocalizedError {
    case server(status: Int, body: String)
    case decoding(Error)

    public var errorDescription: String? {
        switch self {
        case .server(let status, let body):
            return "Analyzer server error \(status): \(body)"
        case .decoding(let error):
            return "Analyzer decoding error: \(error.localizedDescription)"
        }
    }
}

private struct AnalyzerRequestPayload: Encodable {
    let imageBase64: String
    let mimeType: String
}

private struct AnalyzerResponsePayload: Decodable {
    struct PriorsData: Decodable {
        struct StatData: Decodable {
            let mu: Double
            let sigma: Double
        }
        let density: StatData
        let kcalPerG: StatData
    }

    struct Item: Decodable {
        let label: String
        let confidence: Double
        let priors: PriorsData?
        let evidence: [String]?
        let path: String?
        let calories: Double?
        let sigmaCalories: Double?
    }

    let items: [Item]
}

