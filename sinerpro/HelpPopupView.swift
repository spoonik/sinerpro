//
//  HelpPopupView.swift
//  wKeys
//
//  Created by spoonik on 2019/08/28.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import UIKit
import PDFKit

class HelpPopupView: UIView {

    @IBOutlet weak var pdfView: PDFView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        if let documentURL = Bundle.main.url(forResource: "manual", withExtension: "pdf") {
            if let document = PDFDocument(url: documentURL) {
                pdfView.backgroundColor = UIColor.black
                pdfView.autoScales = true
                pdfView.document = document
            }
        }
    }
}
