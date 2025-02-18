//
//  HomeCalenderCollectionViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/13/25.
//

import UIKit
import SnapKit

class HomeCalenderCollectionViewCell: UICollectionViewCell {
    // 지출/수입 금액 데이터
    var inComeMoneys: [Int] = []
    var outComeMoneys: [Int] = []
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.textAlignment = .center
        
        label.text = "13"
        return label
    }()
    
    lazy var inLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.textAlignment = .center
        label.textColor = .blue
        return label
    }()
    
    lazy var outLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubViews() {
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(inLabel)
        self.contentView.addSubview(outLabel)
    }
    
    func setLayout() {
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.black.cgColor
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top).offset(2)
        }
        
        inLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.dateLabel.snp.bottom).offset(2)
        }
        
        outLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.inLabel.snp.bottom).offset(2)
        }
    }
}
