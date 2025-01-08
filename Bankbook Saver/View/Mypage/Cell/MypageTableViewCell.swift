//
//  MypageTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/26/24.
//

import UIKit
import SnapKit

class MypageTableViewCell: UITableViewCell {
    
    lazy var title: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var rightImageText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var rightImage: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        return imageView
    }()
    
    lazy var rightText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func addSubViews() {
        print("MypageTableViewCell - addSubViews() called")
        contentView.addSubview(title)
        contentView.addSubview(rightImageText)
        contentView.addSubview(rightImage)
        contentView.addSubview(rightText)
    }
    
    func setLayout() {
        print("MypageTableViewCell - setLayout() called")
        
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        rightImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        rightImageText.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(rightImage.snp.trailing).offset(-20)
        }
        
        rightText.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
    }

}
