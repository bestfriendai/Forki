//
//  SparkleEventBus.swift
//  Forki
//
//  Event bus for sparkle animations
//

import Combine

final class SparkleEventBus {
    static let shared = SparkleEventBus()
    let sparklePublisher = PassthroughSubject<SparkleType, Never>()
}

enum SparkleType {
    case normalSparkle   // every food log
    case purpleConfetti  // milestone celebrations
}

