//
//  HostingController.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/14.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import Combine

var chordSequence = ChordSequence.sharedManager
// https://stackoverflow.com/questions/56555709/using-environmentobject-in-watchos

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(SequenceView().environmentObject(chordSequence))
        //return AnyView(SequenceView())
    }
}
