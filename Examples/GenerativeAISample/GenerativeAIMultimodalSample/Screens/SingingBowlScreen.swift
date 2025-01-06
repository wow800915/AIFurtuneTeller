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
    @State private var playbackProgress: Double = 0.0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            // 標題區域
            VStack {
                Text("頌缽療癒")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("透過聲音療法放鬆心靈，提升正能量與內在平衡")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            // 音樂播放封面
            Image("singing_bowl") // 替換為音樂相關的圖片
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.bottom, 20)
            
            // 播放進度條
            VStack {
                Slider(value: $playbackProgress, in: 0...1)
                    .accentColor(.blue)
                    .padding(.horizontal, 30)
                    .disabled(true)
                
                Text("播放進度：\(Int(playbackProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            
            // 控制按鈕
            HStack(spacing: 20) {
                Button(action: {
                    if isPlaying {
                        stopMusic()
                    } else {
                        playMusic()
                    }
                }) {
                    HStack {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        Text(isPlaying ? "停止播放" : "開始播放")
                    }
                    .font(.headline)
                    .frame(minWidth: 150, minHeight: 44)
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // 底部備註
            VStack {
                Text("音樂來源：The Rising Sun - TheFealdoProject")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "music", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("音樂檔案載入失敗")
            }
        }
    }
    
    private func playMusic() {
        audioPlayer?.play()
        isPlaying = true
        
        // 啟動計時器來更新進度
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updatePlaybackProgress()
        }
    }
    
    private func stopMusic() {
        audioPlayer?.stop()
        isPlaying = false
        playbackProgress = 0.0
        timer?.invalidate()
    }
    
    private func updatePlaybackProgress() {
        if let player = audioPlayer, player.isPlaying {
            playbackProgress = player.currentTime / player.duration
        } else {
            playbackProgress = 0.0
            timer?.invalidate()
        }
    }
}
