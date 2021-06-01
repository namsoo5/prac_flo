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
        (player?.currentTime ?? 0).convertTimeToPlayTime
    }
    var endTime: String {
        (player?.duration ?? 0).convertTimeToPlayTime
    }
    
    private func requestMusicFile(url: URL, completion: @escaping (Data?) -> Void) {
        AF.request(url)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    completion(data)
                case .failure:
                    completion(nil)
                }
            }
    }
    
    func loadAudioFile(url: URL) {
        player = nil
        requestMusicFile(url: url) { [weak self] data in
            if let data = data {
                self?.player = try? AVAudioPlayer(data: data)
                self?.player?.prepareToPlay()
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
