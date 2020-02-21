//
//  ContentView.swift
//  chording WatchKit Extension
//
//  Created by spoonik on 2019/08/15.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import SwiftUI
import Combine

struct SequenceView: View {
    
    @EnvironmentObject var chordSequence: ChordSequence
    //@ObservedObject var chordSequence = ChordSequence.sharedManager
    
    var body: some View {
        List {
            ForEach(self.chordSequence.sequence) { chord in
                ChordRowView(chord: chord)
                    .listRowPlatterColor(chord.isSeparator() ? Color.black : ChordSequence.sharedManager.sectionColor(at: chord.index))
            }
            .onDelete(perform: self.delete)
            .onMove(perform: self.move)
        }
    }

    func delete(at offsets: IndexSet) {
        //https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-delete-rows-from-a-list
        if let first = offsets.first {
            self.chordSequence.sequence.remove(at: first)
        }
        self.chordSequence.refreshIndexes()
    }
    func move(from source: IndexSet, to destination: Int) {
        //https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-move-rows-in-a-list
        // sort the indexes low to high
        let reversedSource = source.sorted()
        // then loop from the back to avoid reordering problems
        for index in reversedSource.reversed() {
            let src = self.chordSequence.sequence.remove(at: index)
            src.index = 0
            self.chordSequence.refreshIndexes()
            if self.chordSequence.sequence.count > destination {
                self.chordSequence.sequence.insert(src, at: destination)
            } else {
                self.chordSequence.sequence.append(src)
            }
            self.chordSequence.refreshIndexes()
        }
    }
}

struct ChordRowView: View {
    var chord: OneChordModel
    var body: some View {
        Button(action: self.play) {
            Text(self.chord.toString())
                .foregroundColor(Color.white)
        }
    }
    
    func play() {
        if !self.chord.isSeparator() {
            AudioFilesChordPlayer.sharedManager.playPatchOn(chord: self.chord)
        }
    }
}

#if DEBUG
struct SequenceView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceView()
        //SequenceView().environmentObject(ChordSequence())
    }
}
#endif
