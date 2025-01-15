//
//  WebViewScreen.swift
//  GenerativeAISample
//
//  Created by Wei-you Chen on 2024/10/31.
//

import SwiftUI
import WebKit

struct WebViewScreen: View {
    @State private var selectedURL: String = "https://www.taiwan.net.tw/welcome_page.html"

    var body: some View {
        VStack {
            Text("其他探索")
                .font(.headline)
                .padding(.top, 20)
            
            // 新增提示文字
            Text("以下資源鏈接均為外部網站，請依據您的需求自行選擇使用。")
                .font(.system(size: 12)) // 使用更小的字體
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            
            // 4 個按鈕橫向排列
            HStack(spacing: 15) {
                Button(action: {
                    selectedURL = "https://www.taiwan.net.tw/welcome_page.html"
                }) {
                    Text("旅遊")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://www.ncl.edu.tw/"
                }) {
                    Text("圖書館")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://iplay.sa.gov.tw/"
                }) {
                    Text("運動場")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://www.gov.tw/"
                }) {
                    Text("健康")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            
            // WebView 顯示區域
            WebView(urlString: $selectedURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
