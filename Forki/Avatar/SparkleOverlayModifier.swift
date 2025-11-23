//
//  SparkleOverlayModifier.swift
//  Forki
//
//  View modifier to overlay sparkle animations
//

import SwiftUI
import Combine

struct SparkleOverlayModifier: ViewModifier {
    @State private var activeSparkle: SparkleType?
    @State private var showSparkle = false

    private let sparkleStream = SparkleEventBus.shared.sparklePublisher

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showSparkle, let sparkleType = activeSparkle {
                        SparkleView(sparkleType: sparkleType)
                            .transition(.opacity)
                            .allowsHitTesting(false)
                            .frame(
                                width: sparkleType == .purpleConfetti ? 270 : 230, // Frame to surround avatar (200x200)
                                height: sparkleType == .purpleConfetti ? 270 : 230 // Frame to surround avatar (200x200)
                            )
                            .onAppear {
                                // Longer duration for purple confetti to allow 2 loops
                                let duration = sparkleType == .purpleConfetti ? 5.0 : 2.0
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    withAnimation {
                                        showSparkle = false
                                    }
                                }
                            }
                    }
                }
            )
            .onReceive(sparkleStream) { event in
                activeSparkle = event
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSparkle = true
                }
            }
    }
}

