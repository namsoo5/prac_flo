//
//  TimeInterval+.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation

extension TimeInterval {
    var convertTimeToPlayTime: String {
        let min = Int(self / 60)
        let sec = Int(self.truncatingRemainder(dividingBy: 60))
        let timerString = String(format: "%02d:%02d", min, sec)
        
        return timerString
    }
}
