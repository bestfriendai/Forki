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
                LottieWrapper(filename: "Sparkle", isDotLottie: false, loopMode: .playOnce)
                    .scaleEffect(0.65) // Reduced to fit within avatar stage
                    .opacity(play ? 1 : 0)

            case .purpleConfetti:
                LottieWrapper(filename: "Confetti_Purple", isDotLottie: false, loopMode: .repeat(2)) // Loop twice
                    .scaleEffect(1.5) // Size to surround avatar stage
                    .opacity(play ? 1 : 0)
                    .shadow(color: Color.purple.opacity(0.5), radius: 25) // Shadow for depth
            }
        }
        .onAppear {
            play = true
            // Longer duration for purple confetti to allow 2 loops
            let duration = sparkleType == .purpleConfetti ? 5.0 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                play = false
            }
        }
    }
}

struct LottieWrapper: UIViewRepresentable {
    let filename: String
    let isDotLottie: Bool
    let loopMode: LottieLoopMode

    func makeUIView(context: Context) -> LottieAnimationView {
        var view: LottieAnimationView
        
        if isDotLottie {
            // Try multiple approaches for dotLottie files
            var animation: LottieAnimation?
            
            // 1. Try with .lottie extension
            animation = LottieAnimation.named("\(filename).lottie")
            
            // 2. Try without extension (as dotLottie)
            if animation == nil {
                animation = LottieAnimation.named(filename)
            }
            
            // 3. Try as JSON file (fallback if .lottie doesn't work)
            if animation == nil {
                print("⚠️ [Lottie] Could not load \(filename).lottie, trying JSON fallback...")
                animation = LottieAnimation.named("\(filename).json")
            }
            
            // 4. Try loading from bundle path directly
            if animation == nil {
                if let path = Bundle.main.path(forResource: filename, ofType: "lottie") {
                    animation = LottieAnimation.filepath(path)
                }
            }
            
            // 5. Try JSON path as last resort
            if animation == nil {
                if let path = Bundle.main.path(forResource: filename, ofType: "json") {
                    animation = LottieAnimation.filepath(path)
                }
            }
            
            if let anim = animation {
                view = LottieAnimationView(animation: anim)
            } else {
                print("❌ [Lottie] Failed to load animation: \(filename)")
                // Create empty view as fallback
                view = LottieAnimationView()
            }
        } else {
            // For JSON files, try loading with name first
            var animation: LottieAnimation?
            let tempView = LottieAnimationView(name: filename)
            
            if tempView.animation != nil {
                animation = tempView.animation
                print("✅ [Lottie] Successfully loaded \(filename).json")
            } else {
                print("⚠️ [Lottie] Could not load \(filename).json - checking bundle...")
                // Try loading from bundle path directly as fallback
                if let path = Bundle.main.path(forResource: filename, ofType: "json") {
                    print("✅ [Lottie] Found path: \(path)")
                    animation = LottieAnimation.filepath(path)
                    if animation != nil {
                        print("✅ [Lottie] Successfully loaded \(filename).json from bundle path")
                    }
                } else {
                    print("❌ [Lottie] File not found in bundle: \(filename).json")
                }
            }
            
            // Create view with the loaded animation or empty
            if let anim = animation {
                view = LottieAnimationView(animation: anim)
            } else {
                view = LottieAnimationView(name: filename) // Final fallback
            }
        }
        
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.backgroundBehavior = .pauseAndRestore
        
        // Only play if animation was loaded
        if view.animation != nil {
            view.play()
        } else {
            print("⚠️ [Lottie] Animation is nil, cannot play: \(filename)")
        }

        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
