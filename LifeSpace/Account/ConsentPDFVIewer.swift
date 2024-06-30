//
//  ConsentPDFViewer.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 6/26/24.
//

import PDFKit
import SwiftUI

struct ConsentPDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
