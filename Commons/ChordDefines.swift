//
//  ChordDefines.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/14.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import Foundation
import SwiftUI

class ChordDefines {
    
    static let NA = -1
    
    static let root_names = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    static let chord_type_names = ["Maj",
                                   "min",
                                   "dom",
                                   "dim",
                                   "aug",
                                   "sus"]
    
    static let scale_triad_type = 1000  //適当なマジックナンバー。大きければ間違いない
    static let triad_chord_type = [0, 0, 1, 0, 1, 0, 3, 0, 3, 1, 0, 3]
        // ダイアトニックスケール上の3音コードを、chord_type_namesのインデックスで表現
    static let tetrad_chord_type = [(0, 1), //Maj7
                                    (2, 0), //dom7
                                    (1, 1), //min7
                                    (0, 1),
                                    (1, 1),
                                    (0, 1),
                                    (3, 2), //dimb5
                                    (2, 0), //dom7
                                    (3, 2),
                                    (1, 1),
                                    (0, 1),
                                    (3, 1)]
        // ダイアトニックスケール上の4音コードを、chord_type_namesのインデックスで表現

    static let chord_detail_type_names = [
                   [" ", "7", "9", "6", "11" /*"69", "13", "a9"*/],
                   [" ", "7", "9", "6", /*"69",*/ "11", /*"a9", "13",*/ "M7"],
                   ["7", "9", "11", "13"],
                   [" ", "7", "b5"],
                   [" ", "7"],
                   ["4", "7", "2"]]

    static let chord_interval_types = [
            /*"Maj":*/[
                    /*" ":*/[0,4,7],
                    /*"7":*/[0,4,7,11],
                    /*"9":*/[0,2,4,7,9,11],
                    /*"6":*/[0,4,7,9],
                    /*"69":[0,2,4,7,9],*/
                    /*"11":*/[0,2,4,5,7,9]
                    /*"13":[0,2,4,5,7,9,11],*/
                    /*"a9":[0,2,4,7],*/
                ],
            /*"min":*/[
                    /*" ":*/[0,3,7],
                    /*"7":*/[0,3,7,10],
                    /*"9":*/[0,2,3,7,10],
                    /*"6":*/[0,3,7,9],
                    /*"11":*/[0,2,3,5,7,10],
                    /*"13":[0,2,3,5,7,9,10],*/
                    /*"a9":[0,2,3,7],*/
                    /*"69":[0,2,3,7,9]],*/
                    /*"M7":*/[0,3,7,11]
                ],
            /*"dom":*/[
                    /*"7":*/[0,4,7,10],
                    /*"9":*/[0,2,4,7,10],
                    /*"11":*/[0,2,4,5,7,10],
                    /*"13":*/[0,2,4,5,7,9,10]
                ],
            /*"dim":*/[
                    /*" ":*/[0,3,6],
                    /*"7":*/[0,3,6,9],
                    /*"m7b5":*/[0,3,6,10]
                ],
            /*"aug":*/[
                    /*" ":*/[0,4,8],
                    /*"7":*/[0,4,8,10]
                ],
            /*"sus":*/[
                    /*"4":*/[0,5,7],
                    /*"7":*/[0,5,7,10],
                    /*"2":*/[0,2,7]
                ]
        ]
    
    static func getChordNameString(root: Int?,
                                   chordType: Int?,
                                   chordDetailType: Int?,
                                   subRoot: Int?) -> String
    {
        var ret = ""
        if (root != nil) {
            ret += ChordDefines.root_names[root!]
            
            if (chordType != nil) {
                ret += " "
                    + ChordDefines.chord_type_names[chordType!]
                    + ChordDefines.chord_detail_type_names[chordType!][chordDetailType!]
                if (subRoot != nil) {
                    if (root != subRoot) {
                        ret += " /" + ChordDefines.root_names[subRoot!]
                    }
                }
            }
        }
        return ret
    }
    
    // MIDI番号でオクターブの計算をするので、直下の音名ファイル名も同じ並びになるようにセットで管理すること
    static let midibass = [48,49,50,51,52,53,54,55,56,57,58,59]
    static let midikeys = [60,61,62,63,64,65,66,67,68,69,70,71]

    // Sine Wave Sound File Names (append ".m4a" as suffix to use)
    // サイン波は低音よりの方がharakamiっぽいので低めにシフトした
    static let midibass_filename = ["C1", "Cs1", "D1", "Ds1", "E1", "F1",
                                    "Fs1", "G1", "Gs1", "A1", "As1", "B1"]
    static let midikeys_filename = ["C2", "Cs2", "D2", "Ds2", "E2", "F2",
                                    "Fs2", "G2", "Gs2", "A2", "As2", "B2"]
    //static let highkeys_filename = ["C3", "Cs3", "D3", "Ds3", "E3", "F3",
    //                              "Fs3", "G3", "Gs3", "A3", "As3", "B3"]
    
    static let colors_literal = [
        "0099FF",   //blue
        "FF0098",   //pink
        "0CAA00",   //green
        "FF9000",   //orange
        "AAAA00",   //yellow
        "9400EE",   //purple
        "888888"    //gray
    ]
    static let defined_colors_literal = [
        Color.blue,
        Color.pink,
        Color.green,
        Color.orange,
        Color.yellow,
        Color.purple,
        Color.gray
    ]
        
}
