//
//  StatsTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit
import SnapKit
import RxSwift

class StatsTableViewCell: UITableViewCell {
    
    let leftButtonTapped = PublishSubject<Void>()
    let rightButtonTapped = PublishSubject<Void>()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    lazy var leftMoveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 15)
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondarySystemGroupedBackground  // 수정 필요
        button.tintColor = .label
        return button
    }()
    
    lazy var rightMoveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 15)
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondarySystemGroupedBackground
        button.tintColor = .label
        return button
    }()
    
    
    lazy var inComeMoneyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    lazy var inComeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "총 수입"
        return label
    }()
    
    lazy var inComeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var withdrawMoneyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    lazy var withdrawTextLabel: UILabel = {
        let label = UILabel()
        label.text = "총 지출"
        return label
    }()
    
    lazy var withdrawStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        leftMoveButton.rx.tap
            .bind(to: leftButtonTapped)
            .disposed(by: disposeBag)
        
        rightMoveButton.rx.tap
            .bind(to: rightButtonTapped)
            .disposed(by: disposeBag)
        
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
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(leftMoveButton)
        self.contentView.addSubview(rightMoveButton)
        
        inComeStackView.addArrangedSubview(inComeTextLabel)
        inComeStackView.addArrangedSubview(inComeMoneyLabel)
        self.contentView.addSubview(inComeStackView)
        
        withdrawStackView.addArrangedSubview(withdrawTextLabel)
        withdrawStackView.addArrangedSubview(withdrawMoneyLabel)
        self.contentView.addSubview(withdrawStackView)
    }
    
    func setLayout() {
        self.contentView.backgroundColor = .systemGroupedBackground
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(self.contentView).offset(20)
        }
        
        leftMoveButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.equalTo(self.rightMoveButton.snp.leading).offset(-8)
        }
        
        rightMoveButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.equalTo(self.contentView).offset(-20)
        }
        
        inComeStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(dateLabel.snp.bottom).offset(25)
            make.leading.equalTo(self.contentView).offset(20)
        }
        
        withdrawStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(inComeStackView.snp.bottom).offset(10)
            make.leading.equalTo(self.contentView).offset(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
        }
    }

}
