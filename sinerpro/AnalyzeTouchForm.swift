//
//  AnalyzeTouchForm.swift
//  sinerpro
//
//  Created by spoonik on 2018/08/19.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import CoreGraphics

// マルチタッチの指の位置関係を判断して、ベース音とコード名に変換して返すstaticクラス
//
class AnalyzeTouchForm {
    
    // このクラスの外部への公開関数は基本的にこれだけ。タッチ位置を複数入れて、コード構成音(必ず4要素)に変換して返す
    static func get_chord_pattern(points: [CGPoint],
                                  bassrect: CGRect,
                                  subbassrect: CGRect?,
                                  chordrect: CGRect,
                                  current_scale_root: Int,
                                  tetrad_prioritized: Bool) -> [Int?] {
        //This func MUST return 4 paired Int [root, chordType, chordDetailType, subRoot]
        if points.count == 0 {
            return [nil, nil, nil, nil]
        }
        let (bass_points, chord_points) = separate_bass_and_chord(points: points, area_w: bassrect.origin.x + bassrect.size.width)
        var root = get_bass(points: bass_points, rect: bassrect)
        var subroot: Int? = nil
        if (subbassrect != nil) {
            subroot = get_bass(points: bass_points, rect: subbassrect!)
        }
        if root == nil && subroot != nil {
            root = subroot
        } else if root != nil && subroot == nil {
            subroot = root
        } else if root == nil && subroot == nil {
            return [nil, nil, nil, nil]
        }
        let sabuns = get_sabuns(points: chord_points)
        
        // from V3.0 new process: relative tension mode
        let (chord_type, detail_chord_type) = convert_sabuns_to_chord_type(
            sabuns: sabuns,
            chordrect: chordrect,
            chord_root: root!,
            current_scale_root: current_scale_root,
            tetrad_prioritized: tetrad_prioritized)

        return [root, chord_type, detail_chord_type, subroot]
    }

    
    static func getTriad(root_of_chord: Int, current_major_scale_root: Int) -> Int {
        var position_in_scale = root_of_chord - current_major_scale_root
        position_in_scale = (position_in_scale >= 0) ? position_in_scale : (position_in_scale + 12)
        return ChordDefines.triad_chord_type[position_in_scale]
    }
    static func getTetrad(root_of_chord: Int, current_major_scale_root: Int) -> (Int, Int) {
        var position_in_scale = root_of_chord - current_major_scale_root
        position_in_scale = (position_in_scale >= 0) ? position_in_scale : (position_in_scale + 12)
        return ChordDefines.tetrad_chord_type[position_in_scale]
    }

    // タッチ位置の配列を、まずX座標でソートして、その後隣同士の距離の差分をX/Yごとにとり二次元配列に変換して返す
    static func get_sabuns(points: [CGPoint]) -> [[CGFloat]] {
        var p = points
        p.sort(by: {$0.x < $1.x})
        var sabun: [[CGFloat]] = []
        if p.count > 1 {
            for i in 0..<p.count-1 {
                sabun.append([p[i].x-p[i+1].x, p[i].y-p[i+1].y])
            }
        }
        else if p.count == 1 {
            sabun.append([0.0]) // 1つしかタッチがない場合特別な値を決めうちで入れる
        }
        return sabun
    }

    //タッチ円の直径
    static let touch_circle_radius: CGFloat = 90.0
    static let sus_dom_threshold_ratio: CGFloat = 2.0
    
    // 座標の差分をコードタイプとテンションの強さに変換する
    static func convert_sabuns_to_chord_type(sabuns: [[CGFloat]], chordrect: CGRect,
                             chord_root: Int, current_scale_root: Int,
                             tetrad_prioritized: Bool) -> (Int?, Int) {
        var chordType: Int? = nil
        var finger_distance: CGFloat = 0.0
        var detailChordType: Int = 0

        // 指の離れ具合の閾値
        var finger_distance_threshold = chordrect.size.width * 0.55
        let aug_sus_distance_threshold = chordrect.size.height * 0.25

        if (sabuns.count == 1) && (sabuns[0].count == 1) {
            if tetrad_prioritized {
                (chordType, detailChordType) = getTetrad(root_of_chord: chord_root,
                    current_major_scale_root: current_scale_root)
            } else {
                chordType = getTriad(root_of_chord: chord_root,
                    current_major_scale_root: current_scale_root)
            }
        } else {
            if sabuns.count == 1 {
                let spaceX = abs(sabuns[0][0])
                let spaceY = sabuns[0][1]
                finger_distance = spaceX
                
                if spaceY > aug_sus_distance_threshold {
                    chordType = 4   //aug
                } else if spaceY < -aug_sus_distance_threshold {
                    chordType = 3   //dim
                } else {
                    chordType = 1   //min
                }
                
            } else if sabuns.count == 2 {
                let spaceX1 = abs(sabuns[0][0])
                let spaceX2 = abs(sabuns[1][0])

                if (spaceX2 / spaceX1) > sus_dom_threshold_ratio {
                    chordType = 2   //dom
                    finger_distance = spaceX2
                } else if (spaceX1 / spaceX2) > sus_dom_threshold_ratio {
                    chordType = 5   //sus
                    finger_distance = spaceX1
                } else {
                    chordType = 0   //Maj
                    finger_distance = spaceX1
                    finger_distance_threshold = chordrect.size.width * 0.25
                }
            }

            finger_distance = max(0.0, finger_distance-touch_circle_radius)

            if chordType != nil {
                detailChordType = ChordDefines.chord_interval_types[chordType!].count - 1
                detailChordType = min(
                    Int(CGFloat(detailChordType) * finger_distance / finger_distance_threshold),
                    detailChordType)
            }
        }

        return (chordType, detailChordType)
    }
    
    // タッチ位置をベース部分とコード部分に分離する。単純なエリア判定だけ
    static func separate_bass_and_chord(points: [CGPoint], area_w: CGFloat) -> ([CGPoint], [CGPoint]) {
        var bass_points: [CGPoint] = []
        var chord_points: [CGPoint] = []
        for p in points {
            if p.x < area_w {
                bass_points.append(p)
            } else {
                chord_points.append(p)
            }
        }
        return (bass_points, chord_points)
    }

    // 入力された1位置をベース音に変換。キーボードImageViewの中での12分割された範囲位置の判定だけ
    static func get_bass(points: [CGPoint], rect: CGRect) -> Int? {
        for p in points {
            let y = p.y - rect.origin.y
            if y < 0 {
                continue
            }
            let key_idx = max(0, Int(y / (rect.height/CGFloat(ChordDefines.root_names.count))))
            if key_idx < ChordDefines.root_names.count {
                return key_idx
            }
        }
        return nil
    }
}
