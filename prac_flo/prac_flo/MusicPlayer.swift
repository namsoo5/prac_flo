//
//  MusicPlayer.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation
import Alamofire
import AVFoundation

protocol MusicPlayerDelegate: AnyObject {
    func didFinishPlaying()
}

final class MusicPlayer: NSObject {
    static let shared: MusicPlayer = MusicPlayer()
    private override init() {
        super.init()
    }
    
    weak var delegate: MusicPlayerDelegate?
    private var player: AVAudioPlayer?
    var curTime: TimeInterval {
        player?.currentTime ?? 0
    }
    var lyrics: [(TimeInterval, String)] = []
    
    private func requestMusicFile(url: URL, completion: @escaping (Data?) -> Void) {
        AF.request(url)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(data)
                case .failure:
                    completion(nil)
                }
            }
    }
    
    func loadAudioFile(url: URL, lyrics: String?) {
        if let lyrics = lyrics {
            self.lyrics = SeparationLyrics(lyrics)
        }
        player = nil
        requestMusicFile(url: url) { [weak self] data in
            if let data = data {
                self?.player = try? AVAudioPlayer(data: data)
                self?.player?.delegate = self
                self?.player?.prepareToPlay()
            } else {
                Log("play error")
            }
        }
    }
    
    func play(completion: @escaping (Bool) -> Void) {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                         options: [.allowBluetooth, .defaultToSpeaker])
        if let player = self.player {
            player.play()
            completion(true)
        } else {
            checkAudioData(repeatTime: 10) {
                completion($0)
            }
        }
    }
    
    // 데이터 로드보다 플레이버튼을 빠르게 누른경우 일정시간 반복해서 데이터를 탐지함
    private func checkAudioData(repeatTime: Int, completion: @escaping (Bool) -> Void) {
        var limitLoadTime = repeatTime
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let player = self?.player {
                player.play()
                timer.invalidate()
                completion(true)
            } else {
                limitLoadTime -= 1
                if limitLoadTime < 0 {
                    timer.invalidate()
                    Log("load error")
                    completion(false)
                }
            }
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
    
    func movePlay(rate: Float) {
        let time = Float(player?.duration ?? 0) * rate
        Log("movePlayTime: \(time)")
        player?.currentTime = TimeInterval(time)
    }
    
    func rateTimeWithPlayTime(rate: Float) -> TimeInterval {
        let time = Float(player?.duration ?? 0) * rate
        return TimeInterval(time)
    }
    
    private func SeparationLyrics(_ lyrics: String) -> [(TimeInterval, String)] {
        var timeWithLyrics: [(TimeInterval, String)] = []
        let lyrcis = lyrics.components(separatedBy: .newlines)
        
        var isSaveLyrics = false
        for s in lyrcis {
            var timeString = ""
            var tempLyrics = ""
            for c in s {
                if c == "[" {
                    isSaveLyrics = false
                } else if c == "]" {
                    isSaveLyrics = true
                } else {
                    if isSaveLyrics {
                        tempLyrics.append(c)
                    } else {
                        timeString.append(c)
                    }
                }
            }
            let time = lyricsTime(timeString)
            timeWithLyrics.append((time, tempLyrics))
        }
        return timeWithLyrics
    }
    
    func lyricsTime(_ time: String) -> TimeInterval {
        let timeGroup = time.components(separatedBy: ":").map { Int($0) ?? 0 }
        let min: Double = Double(timeGroup[0]) * 60.0
        let sec: Double = Double(timeGroup[1])
        let msec: Double = Double(timeGroup[2]) / 1000.0
        return TimeInterval(min + sec + msec)
    }
    
    func timeForIndex(time: TimeInterval) -> Int {
        let mid = lyrics.count / 2
        let midTime = lyrics[mid].0
        
        // 중간보다 시간이 큼 중간부터 탐색
        if time - midTime > 0 {
            for i in mid..<lyrics.count {
                let startTime = lyrics[i].0
                if time < startTime {
                    return i-1 < 0 ? 0 : i-1
                }
            }
        } else if time - midTime < 0 {
            for i in 0...mid {
                let startTime = lyrics[i].0
                if time < startTime {
                    return i-1 < 0 ? 0 : i-1
                }
            }
        } else {
            return mid
        }
        
        return lyrics.count - 1
    }
}

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
}
