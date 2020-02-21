//
//  ChordMaker.swift
//  sinerpro WatchKit Extension
//
//  Created by spoonik on 2018/08/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import WatchKit
import Foundation
import Combine

class ChordMaker: WKInterfaceController {

    @IBOutlet var rootPicker: WKInterfacePicker!
    @IBOutlet var chordTypePicker: WKInterfacePicker!
    @IBOutlet var chordDetailTypePicker: WKInterfacePicker!
    @IBOutlet var onRootPicker: WKInterfacePicker!
    
    @IBOutlet weak var addChordButton: WKInterfaceButton!
    
    var current_root = 0
    var current_chord_type = 0
    var current_chord_type_detail = 0
    var current_on_root = 0

    let picker_delay = 0.15   // Pickerをちょっと移動するたびに更新するとうざい
    //ちょっと止まるまで遅延させる(sec)
    var timer: Timer?   // その遅延を実装するためのタイマー
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        initPickers()
    }
    
    func scheduleUpdateDetailChordType() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: picker_delay, target: self, selector: #selector(ChordMaker.updateDetailTypePicker), userInfo: nil, repeats: false)
    }

    @IBAction func playChordSoundFile() {
        AudioFilesChordPlayer.sharedManager.playPatchOff()
        AudioFilesChordPlayer.sharedManager.playPatchOn(root: current_root,
                            chordType: current_chord_type,
                            chordDetailType: current_chord_type_detail,
                            subRoot: current_on_root)
    }
    
    func initPickers() {
        var rootPickerItems: [WKPickerItem]! = []
        for root_name in ChordDefines.root_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = root_name
            rootPickerItems.append(pickerItem)
        }
        rootPicker.setItems(rootPickerItems)

        
        var onRootPickerItems: [WKPickerItem]! = []
        for root_name in ChordDefines.root_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = "on " + root_name
            onRootPickerItems.append(pickerItem)
        }
        onRootPicker.setItems(onRootPickerItems)


        var chordPickerItems: [WKPickerItem]! = []
        for c in ChordDefines.chord_type_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = c
            chordPickerItems.append(pickerItem)
        }
        chordTypePicker.setItems(chordPickerItems)

        // DetailType depends on current selected 'ChordType'
        updateDetailTypePicker()
    }
    
    @objc func updateDetailTypePicker() {
        var chordDetailPickerItems: [WKPickerItem]! = []
        for t in ChordDefines.chord_detail_type_names[current_chord_type] {
            let pickerItem = WKPickerItem()
            pickerItem.title = t
            chordDetailPickerItems.append(pickerItem)
        }
        chordDetailTypePicker.setItems(chordDetailPickerItems)
        current_chord_type_detail = 0
    }
    
    @IBAction func pushAddChordToSequence() {
        playChordSoundFile()
        let chord = OneChordModel(root: current_root,
                                  chordType: current_chord_type,
                                  chordDetailType: current_chord_type_detail,
                                  subRoot: current_on_root)
        ChordSequence.sharedManager.append(chord: chord)
    }
    @IBAction func pushAddSeparator() {
        ChordSequence.sharedManager.append(chord: OneChordModel())
        refreshVisibleState()
    }
    
    @IBAction func rootPickerChanged(_ value: Int) {
        if current_root == current_on_root {
            current_on_root = value
        }
        current_root = value
        onRootPicker.setSelectedItemIndex(current_on_root)
    }
    @IBAction func chordTypePickerChanged(_ value: Int) {
        current_chord_type = value
        scheduleUpdateDetailChordType()
    }
    @IBAction func chordDetailTypePickerChanged(_ value: Int) {
        current_chord_type_detail = value
    }
    @IBAction func onRootPickerChanged(_ value: Int) {
        current_on_root = value
    }
    
    func refreshVisibleState() {
        let attString = NSMutableAttributedString(string: "＋")
        attString.setAttributes([NSAttributedString.Key.foregroundColor: ChordSequence.sharedManager.sectionUIColor()],
                                range: NSMakeRange(0, attString.length))
        self.addChordButton.setAttributedTitle(attString)
        //addChordButton.setBackgroundColor(ChordSequence.sharedManager.sectionUIColor())
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        refreshVisibleState()

        super.willActivate()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible

        super.didDeactivate()
    }
}
