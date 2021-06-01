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
    
    private var isPlay: Bool = false
    private lazy var playImage: UIImage? = UIImage(named: "play")
    private lazy var pauseImage: UIImage? = UIImage(named: "pause")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTest()
        seekbarAddPanGesture()
        MusicPlayer.shared.delegate = self
    }
    
    @IBAction private func playButtonTouchUpInside(_ sender: Any) {
        isPlay = !isPlay
        if isPlay {
            MusicPlayer.shared.play { [weak self] isPlay in
                if isPlay {
                    DispatchQueue.main.async { [weak self] in
                        self?.songPlayButton.setBackgroundImage(self?.pauseImage, for: .normal)
                    }
                } else {
                    print("play error")
                    self?.isPlay = false
                }
            }
        } else {
            MusicPlayer.shared.pause()
            songPlayButton.setBackgroundImage(playImage, for: .normal)
        }
    }
    
    private func requestTest() {
        APIRequest.shared.requestSongInfo { [weak self] result in
            switch result {
            case .success(let song):
                if let url = URL(string: song.file) {
                    MusicPlayer.shared.loadAudioFile(url: url)
                    self?.songProgressView.isUserInteractionEnabled = true
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
    
    private func seekbarAddPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveSeekbar(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapSeekbar(_:)))
        songProgressView.addGestureRecognizer(panGesture)
        songProgressView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func moveSeekbar(_ gesture: UIPanGestureRecognizer) {
        let pos = gesture.location(in: songProgressView)
        let rate = pos.x / songProgressView.frame.width
        songProgressView.progress = Float(rate)
        
        switch gesture.state {
        case .ended:
            MusicPlayer.shared.movePlay(rate: Float(rate))
        default:
            return
        }
    }
    
    @objc
    private func tapSeekbar(_ gesture: UITapGestureRecognizer) {
        let pos = gesture.location(in: songProgressView)
        let rate = pos.x / songProgressView.frame.width
        songProgressView.progress = Float(rate)
        
        switch gesture.state {
        case .ended:
            MusicPlayer.shared.movePlay(rate: Float(rate))
        default:
            return
        }
    }
    
    private func playReset() {
        songProgressView.progress = 0
        curPlayTimeLabel.text = "00:00"
        songPlayButton.setBackgroundImage(playImage, for: .normal)
    }
}


extension MusicPlayerViewController: MusicPlayerDelegate {
    func didFinishPlaying() {
        MusicPlayer.shared.stop()
        playReset()
    }
}
