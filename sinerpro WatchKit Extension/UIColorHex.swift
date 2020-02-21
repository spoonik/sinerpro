//
//  UIColorHex.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/17.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }

    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}
