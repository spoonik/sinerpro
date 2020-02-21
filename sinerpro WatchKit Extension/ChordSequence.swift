//
//  ChordSequence.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/14.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


final class ChordSequence: ObservableObject {

    @Published var sequence: [OneChordModel] = []

    static let sharedManager: ChordSequence = {
        let instance = ChordSequence()
        return instance
    }()
    fileprivate init() {
        // TODO Saveを復元
    }
    
    func getAt(at: Int) -> OneChordModel? {
        if (at>=0) && (at<sequence.count) {
            return sequence[at]
        }
        return nil
    }
    
    func getCount() -> Int {
        return sequence.count
    }
    
    func refreshIndexes() {
        var i = 0
        for c in sequence {
            c.updateIndex(id: i)
            i += 1
        }
    }
    
    func getSectionId(at: Int = -1) -> Int {
        var separator_num = 0
        if at == -1 {
            for c in sequence {
                if c.isSeparator() {
                    separator_num += 1
                }
            }
        } else {
            var i = 0
            for c in sequence {
                if c.isSeparator() {
                    separator_num += 1
                }
                if i == at { break }
                i += 1
            }
        }
        return separator_num
    }
    
    func sectionUIColor(at: Int = -1) -> UIColor {
        return UIColor(hex: ChordDefines.colors_literal[getSectionId(at: at) % ChordDefines.colors_literal.count], alpha: 1.0)
    }
    func sectionColor(at: Int = -1) -> Color {
        return ChordDefines.defined_colors_literal[getSectionId(at: at) % ChordDefines.defined_colors_literal.count]
        //return Color( sectionUIColor(at: at) )
    }

    func append(chord: OneChordModel) {
        if chord.isSeparator() {
            if ((sequence.count == 0) || sequence.last!.isSeparator()) {
                //To Avoid:
                // 1. First chord becomes Separator
                // 2. Separators continue in a line
                return
            }
        }
        chord.updateIndex(id: sequence.count)
        sequence.append(chord)
        refreshIndexes()
    }
    
    func clear() {
        sequence.removeAll()
    }
}
