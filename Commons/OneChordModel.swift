//
//  OneChordModel.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/14.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import Foundation

class OneChordModel: Identifiable {
    var id = UUID()
    
    let root_: Int
    let chordType_: Int
    let chordDetailType_: Int
    let subRoot_: Int
    
    var index: Int = 0

    init(root: Int = ChordDefines.NA,
         chordType: Int = ChordDefines.NA,
         chordDetailType: Int = ChordDefines.NA,
         subRoot: Int = ChordDefines.NA) {      // with defaults, it becomes 'Separator'
        root_ = root
        chordType_ = chordType
        chordDetailType_ = chordDetailType
        subRoot_ = (subRoot == ChordDefines.NA ? root : subRoot)
    }

    func toString() -> String {
        if isSeparator() {
            return ""
        }
        return ChordDefines.getChordNameString(root: root_,
                                               chordType: chordType_,
                                               chordDetailType: chordDetailType_,
                                               subRoot: subRoot_)
    }
    
    func updateIndex(id: Int) {
        index = id
    }
    
    func serialize() -> [Int] {
        return [root_, chordType_, chordDetailType_, subRoot_]
    }
    
    static func deserialize(tones: [Int]) -> OneChordModel {
        if tones.count > 3 {
            return OneChordModel(root: tones[0],
                       chordType: tones[1],
                       chordDetailType: tones[2],
                       subRoot: tones[3])
        }
        else if tones.count > 2 {
            return OneChordModel(root: tones[0],
                       chordType: tones[1],
                       chordDetailType: tones[2],
                       subRoot: tones[0])
        }
        return OneChordModel()
    }
    
    func isSeparator() -> Bool {
        return (root_==ChordDefines.NA) && (chordType_==ChordDefines.NA)
                && (chordDetailType_==ChordDefines.NA) && (subRoot_==ChordDefines.NA)
    }
    
    static func == (from: OneChordModel, to: OneChordModel) -> Bool {
        return (from.root_ == to.root_)
                && (from.chordType_ == to.chordType_)
                && (from.chordDetailType_ == to.chordDetailType_)
                && (from.subRoot_ == to.subRoot_)
    }
}
