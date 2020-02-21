//
//  PlayChord.swift
//  wKeys
//
//  Created by spoonik on 2018/08/19.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import AVFoundation

// 単一のサイン音ファイル「A2.aif」をピッチ変調してコードとして再生するクラス。これはiOSでしか使えない
//
class BySingleAifModulationChordPlayer: NSObject, PlayChordProtocol {
    let pitches = [SineWavePlayer(), SineWavePlayer(), SineWavePlayer(), SineWavePlayer(), SineWavePlayer()]

    func playPatchOn(root: Int, chordType: Int, chordDetailType: Int, subRoot: Int) {
    //func playPatchOn(bass: String?, chord: String?) {
        playPatchOff()
        var rootpos = 0
        if bass != nil {
            rootpos = ResourceManager.getRootNames().index(of: bass!)!
            if chord == nil {
                pitches[0].startPlay(midiid: ResourceManager.getMIDIKeys()[rootpos], vol: 0.8)
            } else {
                pitches[0].startPlay(midiid: ResourceManager.getMIDIBass()[rootpos], vol: 0.5)
            }
        } else {
            return
        }
        if chord != nil {
            let chord = ResourceManager.getChordIntervals(chord_style: chord!)
            var i = 1
            for k in chord {
                pitches[i].startPlay(midiid: ResourceManager.getMIDIKeys()[(k+rootpos)%12], vol: 0.5)
                i += 1
            }
        }
    }
    func playPatchOff() {
        for p in pitches {
            p.stopPlay()
        }
    }
}

class SineWavePlayer {
    var audioPlayer : AVAudioPlayer!
    var engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let url = Bundle.main.url(forResource:"A2", withExtension: "aif")!
    let f : AVAudioFile
    let effect = AVAudioUnitTimePitch()

    init() {
        self.engine.stop()
        self.engine = AVAudioEngine()
      
        f = try! AVAudioFile(forReading: url)
        self.engine.attach(player)

        // add some effect nodes to the chain
        //effect.rate = 1.0
        self.engine.attach(effect)
        self.engine.connect(player, to: effect, format: f.processingFormat)
      
        // patch last node into self.engine mixer and start playing first sound
        let mixer = self.engine.mainMixerNode
        self.engine.connect(effect, to: mixer, format: f.processingFormat)

        self.engine.prepare()
        try! self.engine.start()
    }
  
    func startPlay(midiid: Int, vol: Float) {
        effect.pitch = convertMIDIIdToPitch(midiid: midiid)
        player.scheduleFile(f, at: nil) {
            print("stopping")
        }
        player.play()
    }
  
    func stopPlay() {
      self.player.stop()
    }
  
    func convertMIDIIdToPitch(midiid: Int) -> Float {
        return Float((midiid-69)*100)
    }
}
