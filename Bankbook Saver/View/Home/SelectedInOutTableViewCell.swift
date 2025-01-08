//
//  SelectedInOutTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/8/25.
//

import UIKit
import SnapKit

class SelectedInOutTableViewCell: UITableViewCell {

    lazy var selectedInOutView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
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
        print("SelectedInOutTableViewCell - addSubViews() called")
        self.contentView.addSubview(selectedInOutView)
    }
    
    func setLayout() {
        print("SelectedInOutTableViewCell - setLayout() called")
        
        // 캘린더 뷰
        selectedInOutView.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(self.contentView).offset(15)
            make.centerX.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView.snp.bottom)
        }
        
    }

}
