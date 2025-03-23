//
//  NotiSettingTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/4/25.
//

import UIKit
import SnapKit
import RxSwift

class NotiSettingTableViewCell: UITableViewCell {
    
    let notiSwitchState = PublishSubject<Bool>()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var notiSwitch: UISwitch = {
        let notiSwitch = UISwitch()
        return notiSwitch
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubViews()
        setLayout()
        
        notiSwitch.rx.isOn
            .bind(to: notiSwitchState)
            .disposed(by: disposeBag)
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
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subTitleLabel)
        self.contentView.addSubview(notiSwitch)
    }
    
    func setLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(10)
            make.leading.equalTo(self.contentView.snp.leading).offset(10)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
            make.leading.equalTo(self.contentView.snp.leading).offset(10)
        }
        
        notiSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
        }
    }
    
}
