//
//  DetailLyricsView.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/03.
//

import UIKit

/**
 ~~~
 // 필수구현함수
 func config(model: Song)
 ~~~
 */
final class DetailLyricsView: UIView {
    private lazy var titleLabel = createLabel(font: .systemFont(ofSize: 19, weight: .bold))
    private lazy var singerLabel = createLabel(font: .systemFont(ofSize: 14, weight: .semibold))
    private lazy var titleView: UIView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        $0.addSubview(titleLabel)
        $0.addSubview(singerLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(8)
        }
        singerLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        let cancelButton = UIButton(type: .system)
        $0.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(30)
            $0.centerY.equalToSuperview()
        }
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
        cancelButton.setImage(UIImage(named: "xmark"), for: .normal)
        cancelButton.tintColor = .white
        return $0
    }(UIView())
    
    private var songProgressView: UIProgressView!
    private var playButton: UIButton!
    private lazy var playImage: UIImage? = UIImage(named: "play")
    private lazy var pauseImage: UIImage? = UIImage(named: "pause")
    private lazy var bottomView: UIView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        songProgressView = UIProgressView()
        songProgressView.progress = 0
        songProgressView.tintColor = .purple
        seekbarAddPanGesture()
        $0.addSubview(songProgressView)
        songProgressView.snp.makeConstraints {
            $0.height.equalTo(7)
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        playButton = UIButton()
        if isPlay {
            playButton.setBackgroundImage(pauseImage, for: .normal)
        } else {
            playButton.setBackgroundImage(playImage, for: .normal)
        }
        playButton.tintColor = .white
        $0.addSubview(playButton)
        playButton.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(songProgressView.snp.bottom).offset(16)
        }
        playButton.addTarget(self, action: #selector(playButtonTouchUpInside), for: .touchUpInside)
        return $0
    }(UIView())
    
    private lazy var tableView: UITableView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.top.equalTo(titleView.snp.bottom)
        }
        return $0
    }(UITableView())
    
    private var model: Song?
    private lazy var observedLyricsButton: UIButton = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(30)
            $0.top.equalTo(titleView.snp.bottom).offset(32)
        }
        $0.addTarget(self, action: #selector(observerdLyricsButtonTouchUpInside), for: .touchUpInside)
        $0.setImage(UIImage(named: "focus") , for: .normal)
        $0.tintColor = .white
        return $0
    }(UIButton())
    
    private lazy var isCanTouchLyricsButton: UIButton = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.trailing.equalTo(observedLyricsButton.snp.trailing)
            $0.width.height.equalTo(30)
            $0.top.equalTo(observedLyricsButton.snp.bottom).offset(24)
        }
        $0.addTarget(self, action: #selector(canTouchLyricsButtonTouchUpInside), for: .touchUpInside)
        $0.setImage(UIImage(named: "touchLyrics") , for: .normal)
        $0.tintColor = .white
        return $0
    }(UIButton())
    
    var isPlay: Bool!
    
    func config(model: Song, isPlay: Bool) {
        self.isPlay = isPlay
        self.model = model
        titleLabel.text = model.title
        singerLabel.text = model.singer
        
        showView()
        
        self.backgroundColor = .black
        titleView.backgroundColor = .black
        bottomView.backgroundColor = .black
        tableView.backgroundColor = .black
        observedLyricsButton.tintColor = .white
        isCanTouchLyricsButton.tintColor = .white
        
        createTableView()
        if isPlay {
            playProgress()
        }
    }
    
    private func createLabel(text: String = "", font: UIFont) -> UILabel {
        let label: UILabel = {
            $0.text = text
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = font
            return $0
        }(UILabel())
        return label
    }
    
    func showView() {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.alpha = 1
        }
    }
   
    @objc
    private func cancelButtonTouchUpInside() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.layoutIfNeeded()
            self?.alpha = 0
        } completion: { [weak self] _ in
            self?.isHidden = true
        }
    }
    
    @objc
    private func observerdLyricsButtonTouchUpInside() {
        observedLyricsButton.isSelected = !observedLyricsButton.isSelected
        isObservedCurRow = observedLyricsButton.isSelected
        observedLyricsButton.tintColor = observedLyricsButton.isSelected ? .purple : .white
    }
   
    @objc
    private func canTouchLyricsButtonTouchUpInside() {
        isCanTouchLyricsButton.isSelected = !isCanTouchLyricsButton.isSelected
        tableView.allowsSelection = isCanTouchLyricsButton.isSelected
        isCanTouchLyricsButton.tintColor = isCanTouchLyricsButton.isSelected ? .purple : .white
    }
    
    
    @objc
    private func playButtonTouchUpInside() {
        isPlay = !isPlay
        
        if isPlay {
            MusicPlayer.shared.play { [weak self] isPlay in
                if isPlay {
                    DispatchQueue.main.async { [weak self] in
                        self?.playProgress()
                        self?.playButton.setBackgroundImage(self?.pauseImage, for: .normal)
                    }
                } else {
                    print("play error")
                    self?.isPlay = false
                    self?.playButton.setBackgroundImage(self?.playImage, for: .normal)
                }
            }
        } else {
            pauseProgress()
            MusicPlayer.shared.pause()
            playButton.setBackgroundImage(playImage, for: .normal)
        }
    }
    
    var playerTimer: Timer?
    var beforeIndex: Int = 0
    var isObservedCurRow: Bool = false
    
    private func createTableView() {
        tableView.allowsSelection = false
        
        tableView.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(StringCell.self, forCellReuseIdentifier: StringCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    private var isProgressDrag: Bool = false
    private var isScrolled: Bool = false
    private func playProgress(duration: TimeInterval = 0.01) {
        guard let model = model else {
            return
        }
        playerTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] timer in
            if !(self?.isProgressDrag ?? false) {
                if Int(MusicPlayer.shared.curTime) > (self?.model?.duration ?? 0) {
                    self?.playerTimer?.invalidate()
                }
                let rate =  Float(MusicPlayer.shared.curTime) / Float(model.duration)
                UIView.animate(withDuration: 1) { [weak self] in
                    self?.songProgressView.setProgress(rate, animated: true)
                }
                
                let index = MusicPlayer.shared.timeForIndex(time: MusicPlayer.shared.curTime)
                if index == self?.beforeIndex {
                    return
                }
                
                let beforeIndexPath = IndexPath(row: self?.beforeIndex ?? 0, section: 0)
                let beforeCell = self?.tableView.cellForRow(at: beforeIndexPath) as? StringCell
                beforeCell?.highlightingLabel(isHightlight: false)
                
                let indexPath = IndexPath(row: index, section: 0)
                let cell = self?.tableView.cellForRow(at: indexPath) as? StringCell
                cell?.highlightingLabel(isHightlight: true)
                
                if (self?.isObservedCurRow ?? false) && !(self?.isScrolled ?? false) {
                    self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    self?.layoutIfNeeded()
                }
                self?.beforeIndex = index
            }
        }
    }
    
    private func pauseProgress() {
        playerTimer?.invalidate()
    }

    func playReset() {
        playerTimer?.invalidate()
        songProgressView.progress = 0
        playButton.setBackgroundImage(playImage, for: .normal)
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
}

extension DetailLyricsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicPlayer.shared.lyrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StringCell.identifier,
                                                 for: indexPath) as! StringCell
        let curLyrics = MusicPlayer.shared.lyrics[indexPath.row]
        cell.bind(text: curLyrics.1)
        cell.selectionStyle = .none
        return cell
    }
}

extension DetailLyricsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sec = MusicPlayer.shared.lyrics[indexPath.row].0
        MusicPlayer.shared.movePlay(sec: sec)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolled = false
    }
}
