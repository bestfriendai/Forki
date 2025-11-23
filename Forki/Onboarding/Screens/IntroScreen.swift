//
//  IntroScreen.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI
import AVKit

struct IntroScreen: View {
    @Binding var currentScreen: Int
    @ObservedObject var userData: UserData

    // State
    @State private var showConfetti: Bool = false

    var body: some View {
        ZStack {
            ForkiTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                headerBranding
                
                Spacer()
                    .frame(height: 8)
                
                // Avatar View - Square frame with avatar stage styling
                ZStack {
                    // Avatar stage background - same as HomeScreen
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(ForkiTheme.avatarStageBackground)
                        .overlay(
                            // Pixelated starfield effect
                            ZStack {
                                // Small white stars
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 3, height: 3)
                                    .offset(x: -60, y: -80)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 3, height: 3)
                                    .offset(x: 80, y: -60)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 2, height: 2)
                                    .offset(x: -40, y: 100)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 3, height: 3)
                                    .offset(x: 100, y: 80)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 2, height: 2)
                                    .offset(x: -20, y: -40)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 3, height: 3)
                                    .offset(x: 60, y: 40)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color(hex: "#7B68C4"), lineWidth: 4) // Purple border - border-4
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 14)
                    
                    // Avatar video view - square, clean, centered
                    AvatarVideoView(videoName: "forki_intro")
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: min(UIScreen.main.bounds.width - 88, 300), 
                               height: min(UIScreen.main.bounds.width - 88, 300))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .frame(width: min(UIScreen.main.bounds.width - 88, 300), 
                       height: min(UIScreen.main.bounds.width - 88, 300))
                .padding(.horizontal, 16)
                
                VStack(spacing: 12) {
                    Text("Ready to eat healthier?")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Build stronger habits each day —\nwith your own pet, Forki.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .lineSpacing(4)
                }
                .padding(.top, 8)
                
                VStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut) { currentScreen = 1 }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("Let's Get Started!")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#8B5CF6"), // Vibrant purple
                                            Color(hex: "#A78BFA")  // Lighter vibrant purple
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color(hex: "#7B68C4"), lineWidth: 2) // Purple border matching theme
                                )
                        )
                        .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 16, x: 0, y: 8) // Purple glow
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Join thousands of students boosting their habits with joy.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
            
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }


    // MARK: - Branding
    private var headerBranding: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FORKI")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(ForkiTheme.logo)
                    .shadow(color: ForkiTheme.logoShadow.opacity(0.35), radius: 6, x: 0, y: 4)
                Text("NUTRITION PET")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
                    .tracking(1.6)
            }
            Spacer()
        }
    }
}


// MARK: - Confetti
struct ConfettiView: View {
    @State private var particles: [UUID] = (0..<30).map { _ in UUID() }
    var body: some View {
        GeometryReader { geo in
            ForEach(particles, id: \.self) { _ in
                Circle()
                    .fill([Color.red, .yellow, .green, .blue, .pink, .purple].randomElement()!)
                    .frame(width: 8, height: 8)
                    .position(x: .random(in: 0..<geo.size.width),
                              y: .random(in: 0..<geo.size.height/2))
            }
        }
    }
}


// MARK: - Avatar Video View (No Controls)
struct AvatarVideoView: View {
    let videoName: String
    @State private var player: AVPlayer?
    
    init(videoName: String = "forki_intro") {
        self.videoName = videoName
    }
    
    var body: some View {
        Group {
            if player != nil {
                IntroVideoPlayerView(player: player)
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        player?.play()
                    }
                    .onDisappear {
                        player?.pause()
                    }
            } else {
                // Fallback placeholder while video loads
                Color.clear
            }
        }
        .onAppear {
            setupVideo()
        }
    }
    
    private func setupVideo() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("Could not find \(videoName).mp4")
            return
        }
        
        // Clean up previous player and observers
        if let existingPlayer = player {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: existingPlayer.currentItem)
        }
        
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .none
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        self.player = newPlayer
        newPlayer.play()
    }
}

// MARK: - Intro Video Player View (No Controls)
struct IntroVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer?
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// MARK: - Player View Container
class PlayerView: UIView {
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

#Preview {
    IntroScreen(currentScreen: .constant(0), userData: UserData())
}

