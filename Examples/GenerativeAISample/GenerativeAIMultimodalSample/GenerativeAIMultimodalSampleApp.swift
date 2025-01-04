// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

@main
struct GenerativeAIMultimodalSampleApp: App {
    @State private var showPageSelectionDialog = false
    @State private var currentScreen = "PhotoReasoningScreen"  // 用 String 代替 Boolean 控制页面状态
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack {
                    HStack {
                        Text("陳老師AI算命")
                            .font(.largeTitle)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            showPageSelectionDialog.toggle()
                        }) {
                            Image(systemName: "ellipsis.circle")
                        }
                        .padding(.trailing)
                    }
                    .frame(height: 44)
                    .padding(.top)
                    
                    Spacer()
                    
                    // 根據 currentScreen 的值來決定顯示哪個視圖
                    if currentScreen == "SingingBowlScreen" {
                        SingingBowlScreen()
                    } else if currentScreen == "PhotoReasoningScreen" {
                        PhotoReasoningScreen()
                    } else {
                        WebViewScreen()
                    }
                }
                .sheet(isPresented: $showPageSelectionDialog) {
                    PageSelectionDialog(currentScreen: $currentScreen)
                }
            }
        }
    }
}

struct PageSelectionDialog: View {
    @Binding var currentScreen: String  // 通過 Binding 修改父視圖的 String 狀態
    @Environment(\.dismiss) var dismiss  // 獲取 dismiss 環境變數以控制視窗消失
    
    var body: some View {
        NavigationStack {
            List {
                // 陳老師 AI 算命
                VStack(alignment: .leading, spacing: 4) {
                    Button("陳老師AI算命") {
                        currentScreen = "PhotoReasoningScreen"  // 切換到 PhotoReasoningScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("探索 AI 算命的創新方式，結合心理健康支持工具。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
                
                // 頌缽療癒
                VStack(alignment: .leading, spacing: 4) {
                    Button("頌缽療癒") {
                        currentScreen = "SingingBowlScreen"  // 切換到 SingingBowlScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("透過聲音振動療法放鬆身心，提升您的正能量與內在平衡。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
                
                // 靈性探索
                VStack(alignment: .leading, spacing: 4) {
                    Button("靈性探索") {
                        currentScreen = "WebViewScreen"  // 切換到 WebViewScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("深入靈性與命理的專業知識，了解更多宇宙能量的奧秘。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
            }
            .navigationTitle("選擇頁面")
        }
        .presentationDetents([.fraction(0.4)])  // 將高度設為整個屏幕的 30%
    }
}
