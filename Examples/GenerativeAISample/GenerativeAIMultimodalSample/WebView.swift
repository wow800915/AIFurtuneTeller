//
//  WebView.swift
//  GenerativeAISample
//
//  Created by Wei-you Chen on 2024/10/31.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("URL 格式無效: \(urlString)")
        }
    }
}
