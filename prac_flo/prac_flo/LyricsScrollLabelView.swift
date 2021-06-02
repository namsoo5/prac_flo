//
//  LyricsScrollLabelView.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/02.
//

import UIKit

/**
 가사를 보여주는 Label
 ~~~
 // 필수 실행함수
 func createScrollAnimation()
 func createLyricsLabel(lyricsInfo: [LyricsInfo])
 func animationLyrics(time: TimeInterval)
 ~~~
*/
final class LyricsScrollLabelView: UIView {
    typealias LyricsInfo = (TimeInterval, String)
    
    private var scrollLayer = CAScrollLayer()
    var duration: TimeInterval = 0
    private var lyricsInfo: [LyricsInfo] = []
    var scrollable: Bool = false
    private var lyricsLabels: [UILabel] = [] // 가사 Label 한 줄씩 저장
    private var beforeHighlightIndex: Int = 0
    
    func createScrollAnimation() {
        scrollLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.layer.addSublayer(scrollLayer)
    }
    
    func createLyricsLabel(lyricsInfo: [LyricsInfo]) {
        reset()
        
        self.lyricsInfo = lyricsInfo
        var totalY: CGFloat = 0
        for (_, lyrics) in lyricsInfo {
            let label = createLabel(y: totalY, text: lyrics)
            scrollLayer.addSublayer(label.layer)
            lyricsLabels.append(label)
            totalY = label.frame.maxY
        }
    }
    
    private func reset() {
        beforeHighlightIndex = 0
        lyricsLabels.removeAll()
        scrollLayer.removeAllAnimations()
        scrollLayer.sublayers?.removeAll()
    }
    
    private func createLabel(y: CGFloat, text: String) -> UILabel {
        let label: UILabel = {
            $0.text = text
            $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.frame = CGRect(x: 0, y: y, width: scrollLayer.frame.width, height: scrollLayer.frame.height/2)
            return $0
        }(UILabel())
        return label
    }
    
    func animationLyrics(time: TimeInterval) {
        let index = timeForIndex(time: time)
        highlightingLabel(index: index)
        scrollLabel(index: index)
    }
    
    private func scrollLabel(index: Int) {
        if index == 0 {
            return
        }
        let posY = index * Int(scrollLayer.frame.height/2)
        scrollLayer.scrollMode = .vertically
        scrollLayer.scroll(to: CGPoint(x: 0, y: posY))
    }
    
    private func timeForIndex(time: TimeInterval) -> Int {
        let mid = lyricsInfo.count / 2
        let midTime = lyricsInfo[mid].0
        
        // 중간보다 시간이 큼 중간부터 탐색
        if time - midTime > 0 {
            for i in mid..<lyricsInfo.count {
                let startTime = lyricsInfo[i].0
                if time < startTime {
                    return i-1 < 0 ? 0 : i-1
                }
            }
        } else if time - midTime < 0 {
            for i in 0...mid {
                let startTime = lyricsInfo[i].0
                if time < startTime {
                    return i-1 < 0 ? 0 : i-1
                }
            }
        } else {
            return mid
        }
        
        return lyricsInfo.count - 1
    }
    
    private func highlightingLabel(index: Int) {
        lyricsLabels[beforeHighlightIndex].textColor = .lightGray
        lyricsLabels[index].textColor = .white
        beforeHighlightIndex = index
    }
}
