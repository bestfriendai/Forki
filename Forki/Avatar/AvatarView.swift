//
//  AvatarView.swift
//  Forki
//
//  Created by Janice C on 9/17/25.
//

import SwiftUI
import AVKit

struct AvatarView: View {
    let state: AvatarState
    @Binding var showFeedingEffect: Bool   // drives sparkles overlay
    var onFeedingComplete: (() -> Void)? = nil
    var size: CGFloat = 120
    var isCircular: Bool = false  // Whether to clip video to circle (for circular frames)
    
    var body: some View {
        ZStack {
            // Avatar video based on state
            // Use .id() to force view recreation when state changes
            AvatarVideoPlayer(
                videoName: videoName(for: state),
                size: size,
                isCircular: isCircular
            )
            .id(state) // Force recreation when state changes

            // Sparkles overlay (Lottie or SwiftUI particles). You already added SparkleView.
            if showFeedingEffect {
                SparkleView(sparkleType: .normalSparkle) // Normal sparkle for feeding effect
                    .frame(width: size * 0.9, height: size * 0.9) // 90% of avatar size to fit within stage
                    .transition(.opacity)
                    .onAppear {
                        // auto-complete after ~1.2s (tweak to match your Lottie length)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showFeedingEffect = false
                            onFeedingComplete?()
                        }
                    }
            }
        }
    }

    private func videoName(for state: AvatarState) -> String {
        let videoName: String
        switch state {
        case .starving:
            videoName = "avatar-starving"
        case .sad:
            videoName = "avatar-sad"
        case .neutral:
            videoName = "avatar-neutral"
        case .happy:
            videoName = "avatar-happy"
        case .strong:
            videoName = "avatar-strong"
        case .overfull:
            videoName = "avatar-overfull"
        case .bloated:
            videoName = "avatar-bloated"
        case .dead:
            videoName = "avatar-dying"
        }
        NSLog("🎬 [AvatarView] State: \(state.rawValue) → Video: \(videoName).mp4")
        print("🎬 [AvatarView] State: \(state.rawValue) → Video: \(videoName).mp4")
        return videoName
    }
    
}

// MARK: - Avatar Video Player (No Controls)
struct AvatarVideoPlayer: View {
    let videoName: String
    let size: CGFloat
    let isCircular: Bool  // Whether to clip video to circle
    @State private var player: AVPlayer?
    @State private var isViewVisible = false
    
    var body: some View {
        Group {
            if player != nil {
                if isCircular {
                    VideoPlayerView(player: player, size: size, isCircular: true)
                        .frame(width: size, height: size)
                        .clipShape(Circle()) // Double-clip to ensure no square edges show
                } else {
                    VideoPlayerView(player: player, size: size, isCircular: false)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            } else {
                // Fallback placeholder while video loads
                if isCircular {
                    Circle()
                        .fill(ForkiTheme.surface.opacity(0.3))
                        .frame(width: size, height: size)
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(ForkiTheme.surface.opacity(0.3))
                        .frame(width: size, height: size)
                }
            }
        }
        .onAppear {
            isViewVisible = true
            setupVideo()
            // Ensure video plays when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ensureVideoPlaying()
            }
        }
        .onDisappear {
            isViewVisible = false
            player?.pause()
        }
        .onChange(of: videoName) { _, _ in
            setupVideo()
            // Ensure new video plays when it changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ensureVideoPlaying()
            }
        }
    }
    
    private func setupVideo() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            NSLog("⚠️ [AvatarVideoPlayer] Could not find \(videoName).mp4 in bundle")
            print("⚠️ [AvatarVideoPlayer] Could not find \(videoName).mp4 in bundle")
            return
        }
        
        NSLog("✅ [AvatarVideoPlayer] Loading video: \(videoName).mp4 from \(url.path)")
        print("✅ [AvatarVideoPlayer] Loading video: \(videoName).mp4")
        
        // Clean up previous player
        // Note: We don't need to manually remove observers - they're tied to the player item
        // When the player is deallocated, observers are automatically removed
        
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .none
        
        // Configure for autoplay - ensure video plays automatically
        newPlayer.isMuted = false // Ensure audio is enabled if needed
        
        // Loop the video by observing when it finishes
        if let currentItem = newPlayer.currentItem {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: currentItem,
                queue: .main
            ) { [weak newPlayer] _ in
                newPlayer?.seek(to: .zero)
                newPlayer?.play()
                NSLog("🔄 [AvatarVideoPlayer] Video looped: \(videoName).mp4")
            }
        }
        
        self.player = newPlayer
        
        // Play immediately if view is visible
        if isViewVisible {
            newPlayer.play()
            NSLog("▶️ [AvatarVideoPlayer] Playing video: \(videoName).mp4")
        }
    }
    
    // Ensure video is playing - call this when view appears or video changes
    private func ensureVideoPlaying() {
        guard isViewVisible, let player = player else { return }
        
        // Check if player is currently playing
        if player.timeControlStatus != .playing {
            player.play()
        }
        
        // Force play after a brief delay to handle any timing issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if isViewVisible && player.timeControlStatus != .playing {
                player.play()
            }
        }
    }
}

// MARK: - Video Player View (No Controls)
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer?
    let size: CGFloat
    let isCircular: Bool  // Whether to clip to circle
    
    func makeUIView(context: Context) -> SizedPlayerView {
        let view = SizedPlayerView(size: size, isCircular: isCircular)
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        // Ensure video plays when view is created
        if let player = player, player.timeControlStatus != .playing {
            DispatchQueue.main.async {
                player.play()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: SizedPlayerView, context: Context) {
        // Update player if it changed
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
            // Ensure new player starts playing
            if let player = player, player.timeControlStatus != .playing {
                DispatchQueue.main.async {
                    player.play()
                }
            }
        }
        uiView.size = size
        uiView.isCircular = isCircular
        uiView.setNeedsLayout()
    }
}

// MARK: - Sized Player View Container
class SizedPlayerView: UIView {
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var size: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }
    
    var isCircular: Bool {
        didSet {
            updateMask()
            setNeedsLayout()
        }
    }
    
    init(size: CGFloat, isCircular: Bool) {
        self.size = size
        self.isCircular = isCircular
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        updateMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        playerLayer.frame = frame
        
        // Update mask when layout changes
        updateMask()
    }
    
    private func updateMask() {
        if isCircular {
            // Create circular mask to ensure no square edges are visible
            // Mask the view's layer (which contains the AVPlayerLayer) to create a perfect circle
            let maskLayer = CAShapeLayer()
            let radius = min(bounds.width / 2, bounds.height / 2, size / 2)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            maskLayer.path = path.cgPath
            maskLayer.frame = bounds
            // Set fill rule to ensure complete masking
            maskLayer.fillRule = .evenOdd
            // Apply mask to the view's layer to clip everything inside (including the player layer)
            layer.mask = maskLayer
            // Ensure mask is properly updated
            layer.masksToBounds = true
            // Also mask the player layer directly for extra safety
            playerLayer.masksToBounds = true
        } else {
            // Remove mask for non-circular views
            layer.mask = nil
            layer.masksToBounds = false
            playerLayer.masksToBounds = false
        }
    }
}
