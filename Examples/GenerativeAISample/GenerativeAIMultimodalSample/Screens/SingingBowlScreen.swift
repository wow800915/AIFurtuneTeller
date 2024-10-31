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
    @State private var playbackProgress: Double = 0.0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // 音樂標題
                Text(screenMessage)
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                
                // 假設的音樂封面
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                // 播放進度條（僅顯示進度，不控制播放）
                Slider(value: $playbackProgress, in: 0...1)
                    .accentColor(.blue)
                    .padding(.horizontal, 30)
                    .disabled(true)  // 禁止用戶操作，僅作為顯示
                
                HStack(spacing: 20) {
                    Button(action: {
                        if isPlaying {
                            stopMusic()
                        } else {
                            playMusic()
                        }
                    }) {
                        Text(isPlaying ? "停止播放" : "開始播放")
                            .font(.title2)
                            .padding()
                            .frame(width: 150)
                            .background(isPlaying ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                setupAudioPlayer()
            }
            .onDisappear {
                timer?.invalidate()  // 停止計時器
            }
            
            // 右下角的小文字
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Music For Meditation: The Rising Sun\nTheFealdoProject")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding([.bottom, .trailing], 10)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    private func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "music", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                
                // 設定計時器來更新進度條
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    updatePlaybackProgress()
                }
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
        playbackProgress = 0.0
    }
    
    private func updatePlaybackProgress() {
        if let player = audioPlayer, player.isPlaying {
            playbackProgress = player.currentTime / player.duration
        } else if !isPlaying {
            playbackProgress = 0.0
            timer?.invalidate()  // 停止更新
        }
    }
}
