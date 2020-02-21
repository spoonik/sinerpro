//
//  AudioFilesPlayer.swift
//  sinerpro WatchKit Extension
//
//  Created by spoonik on 2018/03/27.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//
import WatchKit
import AVFoundation

// 複数持ちのサイン音ファイルを非同期で再生してコードとして再生するクラス。これはiOS/watchOSで使える
// ただしファイルロードのタイミングが遅れて、ちょっとアルペジオ風になってしまう
class AudioFilesChordPlayer: NSObject, PlayChordProtocol {
    
    var pitches: [PlayPureTone] = []
  
    static let sharedManager: AudioFilesChordPlayer = {
        let instance = AudioFilesChordPlayer()
        return instance
    }()
  
    fileprivate override init() {
        super.init()
        
        // Background Sound On
        let session = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.duckOthers, .mixWithOthers])
        } catch  {
            fatalError("Failed Background mode set")
        }
        do {
            try session.setActive(true)
        } catch {
            fatalError("Failed activate audio session")
        }
    }
    
    func playPatchOn(chord: OneChordModel) {
        playPatchOn(root: chord.root_,
                    chordType: chord.chordType_,
                    chordDetailType: chord.chordDetailType_,
                    subRoot: chord.subRoot_)
    }

    func playPatchOn(root: Int?, chordType: Int?, chordDetailType: Int?, subRoot: Int?) {
        if root == nil {
            return
        }
        
        playPatchOff()
        pitches = []
        
        let trueRoot = (subRoot != ChordDefines.NA ? subRoot! : root!)
        pitches.append(PlayPureTone(index: ChordDefines.midibass[trueRoot], volume: 0.7))

        if chordType != nil && chordDetailType != nil {
            let chordTones = ChordDefines.chord_interval_types[chordType!][chordDetailType!]
            for t in chordTones {
                pitches.append(PlayPureTone(index: ChordDefines.midikeys[(t+root!)%12], volume: 0.6))
            }
        }

        var simultanous: TimeInterval = 0.05
        if pitches.count > 0 {
            simultanous = simultanous + pitches[0].player.deviceCurrentTime
        }
        for p in pitches {
            p.playSoundFile(vol: 0.5, atTime: simultanous)
        }
    }
    func playPatchOff() {
        for p in pitches {
            p.stopSoundFile()
        }
        pitches = []
    }
}

class PlayPureTone: NSObject {
    var player: AVAudioPlayer! = nil
    var filename = ""
    let max_volume: Float

    // TODO: consts
    let fadeDuration = 0.15 //sec
    let sampleSoundLengthDefined = 1.5 //sec
    let min_volume: Float = 0.0

    var timer: Timer?

    init(index: Int, volume: Float) {
        max_volume = volume
        if let id = ChordDefines.midikeys.firstIndex(of: index) {
            filename = ChordDefines.midikeys_filename[id]
        }
        if let id = ChordDefines.midibass.firstIndex(of: index) {
            filename = ChordDefines.midibass_filename[id]
        }
      
        let url = Bundle.main.url(forResource: filename, withExtension: "m4a")
        do {
            try self.player = AVAudioPlayer(contentsOf: url!)
            self.player.volume = self.min_volume
            self.player.prepareToPlay()
        } catch {
            print(error)
        }
    }
    func playSoundFile(vol: Float, atTime: TimeInterval) {
        self.player.play(atTime: atTime)
        self.player.setVolume(max_volume, fadeDuration: self.fadeDuration)
        self.scheduleFadeOut(atTime: self.sampleSoundLengthDefined - self.fadeDuration)
    }
    func stopSoundFile() {
        self.scheduleFadeOut(atTime: 0.0)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: self.fadeDuration, target: self,
                        selector: #selector(PlayPureTone.stopPlay), userInfo: nil, repeats: false)
    }

    @objc func stopPlay() {
        if self.player != nil && !self.player.isPlaying {
            self.player.stop()
            self.player.prepareToPlay()
        }
    }

    func scheduleFadeOut(atTime: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + atTime) {
            self.player.setVolume(self.min_volume, fadeDuration: self.fadeDuration)
        }
    }
}
