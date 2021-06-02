//
//  ViewController.swift
//  prac_flo
//
//  Created by 남수김 on 2021/05/31.
//

import UIKit
import AVFoundation
import SnapKit

final class MusicPlayerViewController: UIViewController {

    @IBOutlet private weak var songTitleLabel: UILabel!
    @IBOutlet private weak var songSingerLabel: UILabel!
    @IBOutlet private weak var songImageView: UIImageView!
    @IBOutlet private weak var songProgressView: UIProgressView!
    @IBOutlet weak var curPlayTimeLabel: UILabel!
    @IBOutlet weak var endPlayTimeLabel: UILabel!
    @IBOutlet private weak var songPlayButton: UIButton!
    private var scrollLyricsLabel: LyricsScrollLabelView!
    
    private var isPlay: Bool = false
    private lazy var playImage: UIImage? = UIImage(named: "play")
    private lazy var pauseImage: UIImage? = UIImage(named: "pause")
    
    private var playerTimer: Timer?
    private var model: Song?
    private var isProgressDrag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createScrollLyricsView()
        requestTest()
        seekbarAddPanGesture()
        MusicPlayer.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func createScrollLyricsView() {
        scrollLyricsLabel = LyricsScrollLabelView()
        scrollLyricsLabel.duration = 1
        view.addSubview(scrollLyricsLabel)
        scrollLyricsLabel.snp.makeConstraints {
            $0.top.equalTo(songImageView.snp.bottom).offset(16)
            $0.leading.equalTo(songImageView.snp.leading)
            $0.trailing.equalTo(songImageView.snp.trailing)
            $0.height.equalTo(34)
        }
        view.layoutIfNeeded()
        scrollLyricsLabel.createScrollAnimation()
    }
    
    @IBAction private func playButtonTouchUpInside(_ sender: Any) {
        if model == nil {
            return
        }
        
        isPlay = !isPlay
        if isPlay {
            MusicPlayer.shared.play { [weak self] isPlay in
                if isPlay {
                    DispatchQueue.main.async { [weak self] in
                        self?.playProgress()
                        self?.songPlayButton.setBackgroundImage(self?.pauseImage, for: .normal)
                    }
                } else {
                    print("play error")
                    self?.isPlay = false
                    self?.songPlayButton.setBackgroundImage(self?.playImage, for: .normal)
                }
            }
        } else {
            pauseProgress()
            MusicPlayer.shared.pause()
            songPlayButton.setBackgroundImage(playImage, for: .normal)
        }
    }
    
    private func requestTest() {
        APIRequest.shared.requestSongInfo { [weak self] result in
            switch result {
            case .success(let song):
                self?.model = song
                if let url = URL(string: song.file) {
                    MusicPlayer.shared.loadAudioFile(url: url, lyrics: song.lyrics)
                    self?.songProgressView.isUserInteractionEnabled = true
                }
                DispatchQueue.main.async {
                    self?.songTitleLabel.text = song.album
                    self?.songSingerLabel.text = song.singer
                    self?.curPlayTimeLabel.text = "00:00"
                    self?.endPlayTimeLabel.text = TimeInterval(song.duration).convertTimeToPlayTime
                    self?.scrollLyricsLabel.createLyricsLabel(lyricsInfo: MusicPlayer.shared.lyrics)
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
        var pos = gesture.location(in: songProgressView)
        if pos.x < 0 {
            pos.x = 0
        }
        let rate: Float = Float(pos.x) / Float(songProgressView.frame.width)
        songProgressView.progress = rate
        isProgressDrag = true
        let expectTime = MusicPlayer.shared.rateTimeWithPlayTime(rate: rate)
        self.curPlayTimeLabel.text = expectTime.convertTimeToPlayTime
        
        switch gesture.state {
        case .ended:
            MusicPlayer.shared.movePlay(rate: rate)
            isProgressDrag = false
        default:
            return
        }
    }
    
    @objc
    private func tapSeekbar(_ gesture: UITapGestureRecognizer) {
        let pos = gesture.location(in: songProgressView)
        let rate = pos.x / songProgressView.frame.width
        songProgressView.progress = Float(rate)
        isProgressDrag = true
        
        switch gesture.state {
        case .ended:
            MusicPlayer.shared.movePlay(rate: Float(rate))
            isProgressDrag = false
        default:
            return
        }
    }
    
    private func playReset() {
        playerTimer?.invalidate()
        songProgressView.progress = 0
        curPlayTimeLabel.text = "00:00"
        songPlayButton.setBackgroundImage(playImage, for: .normal)
    }
    
    private func playProgress(duration: TimeInterval = 0.01) {
        guard let model = model else {
            return
        }
        playerTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] timer in
            // darg상태에서 동작안하도록 설정
            if !(self?.isProgressDrag ?? false){
                self?.curPlayTimeLabel.text = MusicPlayer.shared.curTime.convertTimeToPlayTime
                let rate =  Float(MusicPlayer.shared.curTime) / Float(model.duration)
                self?.scrollLyricsLabel.animationLyrics(time: MusicPlayer.shared.curTime)
                UIView.animate(withDuration: 1) { [weak self] in
                    self?.songProgressView.setProgress(rate, animated: true)
                }
                
                if rate >= 1 {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func pauseProgress() {
        playerTimer?.invalidate()
    }
}


extension MusicPlayerViewController: MusicPlayerDelegate {
    func didFinishPlaying() {
        MusicPlayer.shared.stop()
        playReset()
    }
}


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
        for i in lyricsInfo.indices {
            let startTime = lyricsInfo[i].0
            if time < startTime {
                return i-1 < 0 ? 0 : i-1
            }
        }
        
        return lyricsInfo.count - 1
    }
    
    private func highlightingLabel(index: Int) {
        lyricsLabels[beforeHighlightIndex].textColor = .lightGray
        lyricsLabels[index].textColor = .white
        beforeHighlightIndex = index
    }
}
