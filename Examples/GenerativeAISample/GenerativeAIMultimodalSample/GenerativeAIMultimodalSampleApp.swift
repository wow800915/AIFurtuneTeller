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
                    
                    // 根据 currentScreen 的值来决定显示哪个视图
                    if currentScreen == "SingingBowlScreen" {
                        SingingBowlScreen()
                    } else {
                        PhotoReasoningScreen()
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
    @Binding var currentScreen: String  // 通过 Binding 修改父视图的 String 状态
    
    var body: some View {
        NavigationStack {
            List {
                Button("前往PhotoReasoningScreen") {
                    currentScreen = "PhotoReasoningScreen"  // 切换回 PhotoReasoningScreen
                }
                Button("前往SingingBowlScreen") {
                    currentScreen = "SingingBowlScreen"  // 切换到 SingingBowlScreen
                }
            }
            .navigationTitle("選擇頁面")
        }
        .presentationDetents([.fraction(0.2)])  // 將高度設為整個屏幕的 20%
    }
}
