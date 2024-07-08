//
//  DocumentWebView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 7/7/24.
//

import SwiftUI
import WebKit

struct DocumentWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
