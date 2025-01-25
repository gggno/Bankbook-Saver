//
//  DisplayModeTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/21/25.
//

import UIKit
import SnapKit

class DisplayModeTableViewCell: UITableViewCell {
    
    lazy var modeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addSubViews() {
        self.contentView.addSubview(modeLabel)
        self.contentView.addSubview(checkImageView)
    }
    
    func setLayout() {
        modeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.contentView.snp.leading).offset(10)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
        }
    }

}
