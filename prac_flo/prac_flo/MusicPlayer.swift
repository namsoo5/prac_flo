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
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                         options: [.allowBluetooth, .defaultToSpeaker])
    }
    
    weak var delegate: MusicPlayerDelegate?
    private var player: AVAudioPlayer?
    var curTime: String {
        (player?.currentTime ?? 0).convertTimeToPlayTime
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
    
    func loadAudioFile(url: URL) {
        player = nil
        requestMusicFile(url: url) { [weak self] data in
            if let data = data {
                self?.player = try? AVAudioPlayer(data: data)
                self?.player?.delegate = self
                self?.player?.prepareToPlay()
            } else {
                print("play error")
            }
        }
    }
    
    func play(completion: @escaping (Bool) -> Void) {
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
                    print("load error")
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
        print("movePlayTime: \(time)")
        player?.currentTime = TimeInterval(time)
    }
}

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
}
