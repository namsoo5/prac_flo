//
//  ViewController.swift
//  prac_flo
//
//  Created by 남수김 on 2021/05/31.
//

import UIKit
import AVFoundation

final class MusicPlayerViewController: UIViewController {

    @IBOutlet private weak var songTitleLabel: UILabel!
    @IBOutlet private weak var songSingerLabel: UILabel!
    @IBOutlet private weak var songImageView: UIImageView!
    @IBOutlet private weak var songProgressView: UIProgressView!
    @IBOutlet weak var curPlayTimeLabel: UILabel!
    @IBOutlet weak var endPlayTimeLabel: UILabel!
    @IBOutlet private weak var songPlayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTest()
        
    }
    
    @IBAction private func playButtonTouchUpInside(_ sender: Any) {
        
    }
    
    private func requestTest() {
        APIRequest.shared.requestSongInfo { [weak self] result in
            switch result {
            case .success(let song):
                if let url = URL(string: song.file) {
                    MusicPlayer.shared.loadAudioFile(url: url)
                }
                DispatchQueue.main.async {
                    self?.songTitleLabel.text = song.album
                    self?.songSingerLabel.text = song.singer
                    self?.curPlayTimeLabel.text = "00:00"
                    self?.endPlayTimeLabel.text = TimeInterval(song.duration).convertTimeToPlayTime
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

