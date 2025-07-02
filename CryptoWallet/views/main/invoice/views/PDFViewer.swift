//
//  PDFViewer.swift
//  CryptoWallet
//
//  Created by Mehadi Hasan on 2/7/25.
//

import SwiftUI

import Foundation
import PDFKit
struct PDFViewer:UIViewRepresentable{
    let pdfView = PDFView()
    @Binding var pdffile:String
    
    func makeUIView(context: Context) -> PDFView {
        return pdfView
    }
    func updateUIView(_ uiView: PDFView, context: Context) {
        DispatchQueue.main.async{
            pdfView.document = PDFDocument(url: URL(filePath: pdffile))
            pdfView.displaysAsBook = true
        }
    }
}
