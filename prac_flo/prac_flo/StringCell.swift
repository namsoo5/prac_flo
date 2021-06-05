//
//  StringCell.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/05.
//

import UIKit

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
