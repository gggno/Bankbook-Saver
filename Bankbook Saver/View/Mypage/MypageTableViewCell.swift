//
//  MypageTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/26/24.
//

import UIKit
import SnapKit

class MypageTableViewCell: UITableViewCell {
    
    lazy var menuLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        addSubViews()
        setLayout()
    }
    
    func addSubViews() {
        print("MypageTableViewCell - addSubViews() called")
        contentView.addSubview(menuLabel)
    }
    
    func setLayout() {
        print("MypageTableViewCell - setLayout() called")
        
        menuLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
    }

}
