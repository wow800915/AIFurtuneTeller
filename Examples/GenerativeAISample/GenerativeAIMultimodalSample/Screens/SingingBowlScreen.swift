//
//  SingingBowlScreen.swift
//  GenerativeAIMultimodalSample
//
//  Created by Wei-you Chen on 2024/10/5.
//

import SwiftUI

struct SingingBowlScreen: View {
    var body: some View {
        VStack {
            Spacer()  // 垂直方向上的空白，将内容推向中央
            Text("這是新的頁面：SingingBowlScreen")
                .font(.largeTitle)
            Spacer()  // 垂直方向上的空白，将内容推向中央
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // 使 VStack 占满整个屏幕
    }
}
