//
//  WebViewScreen.swift
//  GenerativeAISample
//
//  Created by Wei-you Chen on 2024/10/31.
//

import SwiftUI
import WebKit

struct WebViewScreen: View {
    @State private var selectedURL: String = "https://www.lnka.tw"

    var body: some View {
        VStack {
            Text("選擇外部命盤系統")
                .font(.headline)
                .padding(.top, 20)
            
            // 4 個按鈕橫向排列
            HStack(spacing: 15) {
                Button(action: {
                    selectedURL = "https://www.lnka.tw"
                }) {
                    Text("靈匣")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://www.ziwei.my"
                }) {
                    Text("紫微麥")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://www.fgs.org.tw"
                }) {
                    Text("佛光山")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedURL = "https://astro.click108.com.tw/star/index.php"
                }) {
                    Text("星座")
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
