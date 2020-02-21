//
//  HelpViewController.swift
//  sinerpro
//
//  Created by spoonik on 2019/08/28.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import UIKit
import PDFKit

class HelpViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func pushDone(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
