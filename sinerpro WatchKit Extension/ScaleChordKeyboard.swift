//
//  ScaleChordKeyboard.swift
//  sinerpro WatchKit Extension
//
//  Created by spoonik on 2019/09/07.
//  Copyright © 2019 spoonikapps. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class ScaleChordKeyboard: WKInterfaceController {
    
    let motionManager = CMMotionManager()

    let chord_type_names = ["Maj",
                            "min",
                            "dom",
                            "dim",
                            "aug"]
    let chord_type_colors = [UIColor(hex: "0CAA00", alpha: 1.0),    //green
                             UIColor(hex: "0099FF", alpha: 1.0),    //blue
                             UIColor(hex: "FF0098", alpha: 1.0),    //pink
                             UIColor(hex: "FF9000", alpha: 1.0),    //orange
                             UIColor(hex: "9400EE", alpha: 1.0)]    //purple

    var alternative_chord_types = [1, 2, 3, 4]
    
    @IBOutlet weak var chordNameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var scaleRootPicker: WKInterfacePicker!
    
    @IBOutlet weak var alternativeChordButton1: WKInterfaceButton!
    @IBOutlet weak var alternativeChordButton2: WKInterfaceButton!
    @IBOutlet weak var alternativeChordButton3: WKInterfaceButton!
    @IBOutlet weak var alternativeChordButton4: WKInterfaceButton!

    var scale_root: Int = 0   //Default 0 = 'C'
    var chord_root: Int = 0
    var chord_altered: Int = -1
    var tenstion_degree = 0.0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        var rootPickerItems: [WKPickerItem]! = []
        for root_name in ChordDefines.root_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = root_name
            rootPickerItems.append(pickerItem)
        }
        scaleRootPicker.setItems(rootPickerItems)
        
        updateAlternativeChordTypes(basicTriad: chord_root)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.3
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.tenstion_degree = 1.0 - abs(accelData!.acceleration.z)
            })
        }
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    func updateAlternativeChordTypes(basicTriad: Int) {
        alternative_chord_types = []
        for i in 0..<chord_type_names.count {
            if i != basicTriad {
                alternative_chord_types.append(i)
            }
        }
        alternativeChordButton1.setTitle(ChordDefines.chord_type_names[alternative_chord_types[0]])
        alternativeChordButton1.setBackgroundColor(chord_type_colors[alternative_chord_types[0]])
        
        alternativeChordButton2.setTitle(ChordDefines.chord_type_names[alternative_chord_types[1]])
        alternativeChordButton2.setBackgroundColor(chord_type_colors[alternative_chord_types[1]])

        alternativeChordButton3.setTitle(ChordDefines.chord_type_names[alternative_chord_types[2]])
        alternativeChordButton3.setBackgroundColor(chord_type_colors[alternative_chord_types[2]])

        alternativeChordButton4.setTitle(ChordDefines.chord_type_names[alternative_chord_types[3]])
        alternativeChordButton4.setBackgroundColor(chord_type_colors[alternative_chord_types[3]])
    }
    
    func playChordSoundFile(scaleRoot: Int, chordRoot: Int, alternative: Int) {
        AudioFilesChordPlayer.sharedManager.playPatchOff()

        var chord_type = ChordDefines.triad_chord_type[chordRoot]  //いったん移調しないでTriadはとる
        updateAlternativeChordTypes(basicTriad: chord_type)
        
        if alternative >= 0 {
            chord_type = alternative_chord_types[alternative]
        }
        var chord_type_detail = Int(Double(ChordDefines.chord_detail_type_names[chord_type].count) * tenstion_degree)
        
        if (chord_type_detail > 0) {
            if (chordRoot == 1 || chordRoot == 7) {  //これらのルート(Db / G)は
                chord_type = alternative_chord_types[1]  //テンションのルートを「dom」として読み替える
                chord_type_detail = Int(Double(ChordDefines.chord_detail_type_names[chord_type].count) * tenstion_degree)
           }
        }
        // Pickerの移調をここで考慮し、ルートの音は読み替える必要がある
        let reassigned_root = (scaleRoot + chordRoot) % 12
        displayChordName(root: reassigned_root, chordType: chord_type, chordDetailType: chord_type_detail)
        
        AudioFilesChordPlayer.sharedManager.playPatchOn(root: reassigned_root,
                            chordType: chord_type,
                            chordDetailType: chord_type_detail,
                            subRoot: reassigned_root)
    }
    
    func displayChordName(root: Int, chordType: Int, chordDetailType: Int) {
        let chord_name = ChordDefines.getChordNameString(root: root,
                            chordType: chordType,
                            chordDetailType: chordDetailType,
                            subRoot: root)
        chordNameLabel.setText(chord_name)
    }
    
    @IBAction func changeScaleRootPicker(_ value: Int) {
        scale_root = value
    }
        
    @IBAction func pushKey1() {
        chord_root = 0
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey2() {
        chord_root = 1
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey3() {
        chord_root = 2
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey4() {
        chord_root = 3
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey5() {
        chord_root = 4
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey6() {
        chord_root = 5
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey7() {
        chord_root = 6
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey8() {
        chord_root = 7
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey9() {
        chord_root = 8
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey10() {
        chord_root = 9
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey11() {
        chord_root = 10
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushKey12() {
        chord_root = 11
        chord_altered = -1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }

    @IBAction func pushAlternativeChord1() {
        chord_altered = 0
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushAlternativeChord2() {
        chord_altered = 1
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushAlternativeChord3() {
        chord_altered = 2
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }
    @IBAction func pushAlternativeChord4() {
        chord_altered = 3
        playChordSoundFile(scaleRoot: scale_root, chordRoot: chord_root, alternative: chord_altered)
    }

}
