//
//  InOutListTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit
import SnapKit

class InOutListTableViewCell: UITableViewCell {
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        return label
    }()
    
    lazy var detailUseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    lazy var detailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailUseLabel, categoryLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        
        return stackView
    }()
    
    lazy var moneyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    lazy var inOutView: UIView = {
        let view = UIView()
//        view.backgroundColor = .systemYellow
        
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubViews()
        setLayout()
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func addSubViews() {
        self.inOutView.addSubview(emojiLabel)
        
        self.inOutView.addSubview(detailStackView)
        
        self.inOutView.addSubview(moneyLabel)
                
        self.contentView.addSubview(inOutView)
    }
    
    func setLayout() {
        self.contentView.backgroundColor = .systemGroupedBackground
        
//        self.inOutView.layer.borderWidth = 1
//        self.inOutView.layer.borderColor = UIColor.green.cgColor
        
        emojiLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview()
            make.size.equalTo(40)
        }
        
        detailStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(emojiLabel.snp.trailing).offset(15)
            make.trailing.lessThanOrEqualTo(moneyLabel.snp.leading).offset(-10)
        }
        
        moneyLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
        
        inOutView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(self.contentView.snp.top)
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
        }
    }

}
