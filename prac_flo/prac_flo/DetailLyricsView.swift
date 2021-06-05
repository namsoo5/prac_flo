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
    
    private lazy var bottomView: UIView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
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
        
    func config(model: Song) {
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
        
        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            if Int(MusicPlayer.shared.curTime) > (self?.model?.duration ?? 0) {
                self?.playerTimer?.invalidate()
            }
            let beforeIndexPath = IndexPath(row: self?.beforeIndex ?? 0, section: 0)
            let beforeCell = self?.tableView.cellForRow(at: beforeIndexPath) as? StringCell
            beforeCell?.highlightingLabel(isHightlight: false)
            
            let index = MusicPlayer.shared.timeForIndex(time: MusicPlayer.shared.curTime)
            let indexPath = IndexPath(row: index, section: 0)
            if (self?.isObservedCurRow ?? false) {
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            let cell = self?.tableView.cellForRow(at: indexPath) as? StringCell
            cell?.highlightingLabel(isHightlight: true)
            self?.beforeIndex = index
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
        Log(indexPath)
        let sec = MusicPlayer.shared.lyrics[indexPath.row].0
        MusicPlayer.shared.movePlay(sec: sec)
    }
}

final class StringCell: UITableViewCell {
    static let identifier: String = "StringCell"
    
    private lazy var label: UILabel = {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .lightGray
        $0.textAlignment = .left
        
        addSubview($0)
        $0.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        return $0
    }(UILabel())
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.textColor = .lightGray
    }
    
    func bind(text: String) {
        backgroundColor = .black
        label.text = text
    }
    
    func highlightingLabel(isHightlight: Bool) {
        label.textColor = isHightlight ? .white : .lightGray
    }
}
