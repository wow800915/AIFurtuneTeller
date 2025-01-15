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
                        Text("AI 打氣王")
                            .font(.title) // 字體縮小到 "title"
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
                // 圖像智能分析
                VStack(alignment: .leading, spacing: 4) {
                    Button("圖像智能分析") {
                        currentScreen = "PhotoReasoningScreen"  // 切換到 PhotoReasoningScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("上傳照片，通過 AI 技術獲取個性化洞察與生活靈感建議。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
                
                // 頌缽聲音療法
                VStack(alignment: .leading, spacing: 4) {
                    Button("頌缽之音") { // 名稱簡化，突出聲音療法
                        currentScreen = "SingingBowlScreen"  // 切換到 SingingBowlScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("利用聲音共振幫助身心放鬆，釋放壓力，體驗內在平衡與能量提升。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
                
                // 趣味探索
                VStack(alignment: .leading, spacing: 4) {
                    Button("其他探索") {
                        currentScreen = "WebViewScreen"  // 切換到 WebViewScreen
                        dismiss()  // 關閉視窗
                    }
                    Text("了解更多與 AI 和身心靈相關的知識，探索全新生活靈感。")
                        .font(.system(size: 12))  // 使用更小的字體
                        .foregroundColor(.secondary)  // 顏色柔和
                }
            }
            .navigationTitle("選擇功能")
        }
        .presentationDetents([.fraction(0.4)])  // 將高度設為整個屏幕的 30%
    }
}
