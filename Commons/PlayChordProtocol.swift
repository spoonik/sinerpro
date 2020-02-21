//
//  PlayChordProtocol.swift
//  sinerpro
//
//  Created by spoonik on 2018/08/25.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

protocol PlayChordProtocol {
    func playPatchOn(root: Int?, chordType: Int?, chordDetailType: Int?, subRoot: Int?)
    func playPatchOff()
}
