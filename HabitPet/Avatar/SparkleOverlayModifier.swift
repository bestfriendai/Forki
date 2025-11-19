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
                            .frame(width: 230, height: 230) // Constrain to avatar circle size
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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

