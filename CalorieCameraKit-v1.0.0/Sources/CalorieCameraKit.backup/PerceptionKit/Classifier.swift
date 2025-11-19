//
//  Classifier.swift
//  CalorieCameraKit
//
//  Created by Janice C on 10/30/25.
//

import Foundation

/// Protocol for food classification implementations
public protocol Classifier {
    /// Classify a food instance from an image mask
    /// - Parameter instance: The food instance mask containing image data
    /// - Returns: A classification result with label, confidence, and top-K results
    func classify(instance: FoodInstanceMask) async throws -> ClassResult
}

/// Represents a food instance mask with RGB image data
public struct FoodInstanceMask {
    /// RGB image data (typically JPEG or PNG)
    public let rgbImageData: Data?
    
    public init(rgbImageData: Data?) {
        self.rgbImageData = rgbImageData
    }
}

