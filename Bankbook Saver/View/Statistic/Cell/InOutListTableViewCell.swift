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
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 75 / 3
        return label
    }()
    
    lazy var moneyLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var detailUseLabel: UILabel = {
        let label = UILabel()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func addSubViews() {
        self.inOutView.addSubview(emojiLabel)
        
        self.inOutView.addSubview(moneyLabel)
        
        self.inOutView.addSubview(detailUseLabel)
        
        self.contentView.addSubview(inOutView)
    }
    
    func setLayout() {
        self.contentView.backgroundColor = .secondarySystemGroupedBackground
        
        emojiLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(50)
        }
        
        detailUseLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(emojiLabel.snp.trailing).offset(20)
        }
        
        moneyLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
        
        inOutView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(self.contentView.snp.top)
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
        }
    }

}
