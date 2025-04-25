//
//  PayDayView.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/10/25.
//

import UIKit
import SnapKit

class PayDayView: UIView {
    lazy var payDayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)

        return label
    }()
    
    lazy var payDayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .label
        return imageView
    }()
    
    init(payTypeText: String, dateText: String) {
        super.init(frame: .zero)
        
        self.payDayLabel.text = payTypeText
        self.dateLabel.text = dateText
        
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubViews() {
        self.addSubview(payDayLabel)
        self.addSubview(dateLabel)
        self.addSubview(payDayImageView)
    }
    
    func setLayout() {
        payDayLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(payDayImageView.snp.leading).offset(-4)
        }
        
        payDayImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(16)
            make.bottom.equalToSuperview()
        }
    }
    
}
