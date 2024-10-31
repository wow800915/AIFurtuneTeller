//
//  SingingBowlScreen.swift
//  GenerativeAIMultimodalSample
//
//  Created by Wei-you Chen on 2024/10/5.
//

import SwiftUI
import AVFoundation

struct SingingBowlScreen: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var screenMessage = "安神寧念"

    var body: some View {
        VStack {
            Spacer()
            
            Text(screenMessage)
                            .font(.largeTitle)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    if isPlaying {
                        stopMusic()
                    } else {
                        playMusic()
                    }
                }) {
                    Text(isPlaying ? "停止播放" : "開始播放")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            setupAudioPlayer()
        }
    }
    
    private func setupAudioPlayer() {
            if let path = Bundle.main.path(forResource: "music", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                } catch {
                    screenMessage = "音樂檔案載入失敗"
                }
            } else {
                screenMessage = "音樂檔案未找到"
            }
        }
    
    private func playMusic() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    private func stopMusic() {
        audioPlayer?.stop()
        isPlaying = false
    }
}
