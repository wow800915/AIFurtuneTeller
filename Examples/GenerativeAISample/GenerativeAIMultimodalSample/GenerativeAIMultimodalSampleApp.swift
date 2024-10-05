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
    var body: some Scene {
        WindowGroup {
            ContentView()  // 使用 TabView 作為主要介面
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PhotoReasoningScreen()
            }
            .tabItem {
                Label("AI算命", systemImage: "photo")
            }
            
            NavigationStack {
                SingingBowlScreen()  // 新增的畫面
            }
            .tabItem {
                Label("唱頌缽", systemImage: "music.note")
            }
        }
    }
}

struct SingingBowlScreen: View {
    var body: some View {
        VStack {
            Text("這是唱頌缽的畫面")
                .font(.title)
                .padding()
            Text("在這裡你可以體驗聲音療癒。")
        }
        .navigationTitle("唱頌缽")
    }
}

#Preview {
    ContentView()
}
