//
//  ViewController.swift
//  sinerpro
//
//  Created by spoonik on 2018/03/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var touchableView: TouchableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ボタン系UI操作
    @IBAction func pushSetTriadScaleRootKey(_ sender: Any) {
        touchableView.setCurrentRootAsTriadsScale()
    }
    @IBAction func pushSetTetradScaleRootKey(_ sender: Any) {
        touchableView.setCurrentRootAsTetradsScale()
    }
}
