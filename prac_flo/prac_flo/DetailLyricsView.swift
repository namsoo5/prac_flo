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
    private lazy var titleView: UIView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        let titleLabel = createLabel(text: title, font: .systemFont(ofSize: 19, weight: .bold))
        let singerLabel = createLabel(text: title, font: .systemFont(ofSize: 14, weight: .semibold))

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
    
    private lazy var scrollView: UIScrollView = {
        self.addSubview($0)
        $0.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.top.equalTo(titleView.snp.bottom)
        }
        return $0
    }(UIScrollView())
    
    private var title: String = ""
    private var singer: String = ""
    
    func config(model: Song) {
        title = model.title
        singer = model.singer
        
        showView()
        
        self.backgroundColor = .black
        titleView.backgroundColor = .black
        bottomView.backgroundColor = .black
        scrollView.backgroundColor = .black
    }
    
    private func createLabel(text: String, font: UIFont) -> UILabel {
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
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.alpha = 1
        } completion: { [weak self] _ in
            self?.isHidden = false
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
}
