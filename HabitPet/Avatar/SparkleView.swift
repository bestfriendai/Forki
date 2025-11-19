//
//  SparkleView.swift
//  Forki
//
//  Unified animation loader for sparkle effects
//

import SwiftUI
import Lottie

struct SparkleView: View {
    let sparkleType: SparkleType
    @State private var play = false

    var body: some View {
        ZStack {
            switch sparkleType {
            case .normalSparkle:
                LottieWrapper(filename: "Sparkle", isDotLottie: false)
                    .scaleEffect(0.65) // Reduced to fit within avatar stage
                    .opacity(play ? 1 : 0)

            case .purpleConfetti:
                LottieWrapper(filename: "Confetti_Purple", isDotLottie: true)
                    .scaleEffect(0.75) // Reduced to fit within avatar stage
                    .opacity(play ? 1 : 0)
                    .shadow(color: Color.purple.opacity(0.5), radius: 20) // Reduced shadow radius
            }
        }
        .onAppear {
            play = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                play = false
            }
        }
    }
}

struct LottieWrapper: UIViewRepresentable {
    let filename: String
    let isDotLottie: Bool

    func makeUIView(context: Context) -> LottieAnimationView {
        let view: LottieAnimationView
        if isDotLottie {
            // For dotLottie files, use the .lottie extension
            if let animation = LottieAnimation.named("\(filename).lottie") {
                view = LottieAnimationView(animation: animation)
            } else {
                // Fallback: try without extension
                view = LottieAnimationView(name: filename)
            }
        } else {
            // For JSON files, use the name directly
            view = LottieAnimationView(name: filename)
        }
        
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        view.play()

        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
