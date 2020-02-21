//
//  TouchableView.swift
//  sinerpro
//
//  Created by spoonik on 2018/08/19.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import UIKit

class TouchableView: UIView {
    var last_root: Int? = nil
    var basicMajorScaleKey = 0
    var tetrad_prioritized = false

    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var touchableStackView: UIStackView!
    @IBOutlet weak var ipadKeyboardStackView: UIStackView!
    @IBOutlet weak var chordLabel: UILabel!
    @IBOutlet weak var keyboardHigh: UIImageView!
    @IBOutlet weak var keyboardLow: UIImageView!
    
    var chord_player: PlayChordProtocol!
    var touchViews = [UITouch:TouchSpotView]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        initChordPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
        initChordPlayer()
    }

    func initChordPlayer() {
        chord_player = AudioUnitMIDISynthChordPlayer()
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            createViewForTouch(touch: touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           let view = viewForTouch(touch: touch)
           // Move the view to the new location.
           let newLocation = touch.location(in: self)
           view?.center = newLocation
        }
        if event != nil {
            playTouches(touches: event!.allTouches!)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           removeViewForTouch(touch: touch)
        }
        chord_player.playPatchOff()
        chordLabel.text = " "
    }

     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           removeViewForTouch(touch: touch)
        }
     }

    func playTouches(touches: Set<UITouch>) {
        var points: [CGPoint] = []
        for touch in touches {
            points.append(touch.location(in: self))
        }
        
        let baseframe = parentStackView.convert(touchableStackView.frame, to: self)
        var keyboard_frame = CGRect(x: baseframe.minX, y: baseframe.minY,
                                    width: baseframe.width*0.25,
                                    height: baseframe.height)
        var keyboard_low_frame: CGRect? = nil
        if (ipadKeyboardStackView != nil) {
            keyboard_frame = touchableStackView.convert(keyboardHigh.frame, to: self)
            keyboard_low_frame = touchableStackView.convert(keyboardLow.frame, to: self)
        }
        let chord_field_frame = CGRect(x: baseframe.minX + baseframe.width*0.25,
                                       y: baseframe.minY,
                                       width: baseframe.width*0.75,
                                       height: baseframe.height)

        let chord_tones = AnalyzeTouchForm.get_chord_pattern(points: points,
                                                             bassrect: keyboard_frame,
                                                             subbassrect: keyboard_low_frame,
                                                             chordrect: chord_field_frame,
                                                             current_scale_root: basicMajorScaleKey,
                                                             tetrad_prioritized: tetrad_prioritized)
        let root = chord_tones[0]
        let chordType = chord_tones[1]
        let chordDetailType = chord_tones[2]
        let subRoot = chord_tones[3]
        
        var chord_text = " "
        
        last_root = root

        chord_text = (root != nil)
            ? ChordDefines.getChordNameString(root: root,
                                    chordType: chordType,
                                    chordDetailType: chordDetailType,
                                    subRoot: subRoot)
            : " "

        if chordLabel.text != chord_text && root != nil {
            chordLabel.text = chord_text
            chord_player.playPatchOn(root: root,
                                     chordType: chordType,
                                     chordDetailType: chordDetailType,
                                     subRoot: subRoot)
        }
    }
    
    public func setCurrentRootAsTriadsScale() {
        basicMajorScaleKey = (last_root != nil ? last_root! : basicMajorScaleKey)
        tetrad_prioritized = false
    }
    public func setCurrentRootAsTetradsScale() {
        basicMajorScaleKey = (last_root != nil ? last_root! : basicMajorScaleKey)
        tetrad_prioritized = true
    }

//-------以下、(TouchSpotViewも含めて)タッチ入力の処理用定型処理 (Appleのサイトからコピペ)--------
    func createViewForTouch( touch : UITouch ) {
       let newView = TouchSpotView()
       newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
       newView.center = touch.location(in: self)
    
       // Add the view and animate it to a new size.
       addSubview(newView)
       UIView.animate(withDuration: 0.2) {
        newView.bounds.size = CGSize(width: AnalyzeTouchForm.touch_circle_radius,
                                     height: AnalyzeTouchForm.touch_circle_radius)
       }
       // Save the views internally
       touchViews[touch] = newView
    }
    func viewForTouch (touch : UITouch) -> TouchSpotView? {
       return touchViews[touch]
    }
    func removeViewForTouch (touch : UITouch ) {
       if let view = touchViews[touch] {
          view.removeFromSuperview()
          touchViews.removeValue(forKey: touch)
       }
    }
}
class TouchSpotView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Update the corner radius when the bounds change.
    override var bounds: CGRect {
      get { return super.bounds }
      set(newBounds) {
         super.bounds = newBounds
         layer.cornerRadius = newBounds.size.width / 2.0
      }
    }
}
