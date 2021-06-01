//
//  MusicPlayer.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation
import Alamofire
import AVFoundation

final class MusicPlayer {
    static let shared: MusicPlayer = MusicPlayer()
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                         options: [.allowBluetooth, .defaultToSpeaker])
    }
    
    private var player: AVAudioPlayer?
    var curTime: String {
        convertTimeToString(player?.currentTime ?? 0)
    }
    var endTime: String {
        convertTimeToString(player?.duration ?? 0)
    }
    
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
    
    private func convertTimeToString(_ time: TimeInterval) -> String {
        let min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let timerString = String(format: "%02d:%02d", min, sec)
        
        return timerString
    }
    
    func loadAudioFile(_ url: URL) {
        player = nil
        requestMusicFile(url: url) { [weak self] data in
            if let data = data {
                self?.player = try? AVAudioPlayer(data: data)
            } else {
                print("play error")
            }
        }
    }
    
    func play() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let player = self?.player {
                player.play()
                timer.invalidate()
            }
        }
    }
    
    func pause() {
        player?.pause()
    }
}
