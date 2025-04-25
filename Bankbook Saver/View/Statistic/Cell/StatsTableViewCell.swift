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
    
    lazy var inComeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.up.forward")
        imageView.tintColor = .blue
        return imageView
    }()
    
    lazy var inComeImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.inComeBg
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        view.addSubview(inComeImageView)
        
        return view
    }()
    
    lazy var inComeLabel: UILabel = {
        let label = UILabel()
        label.text = "수입"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }()
    
    lazy var inComeMoneyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    lazy var inComeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.inComeBg.withAlphaComponent(0.3)
        view.layer.cornerRadius = 10
        view.addSubview(inComeImageBackgroundView)
        view.addSubview(inComeLabel)
        view.addSubview(inComeMoneyLabel)
        
        return view
    }()
    
    lazy var outComeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.down.forward")
        imageView.tintColor = .red
        return imageView
    }()
    
    lazy var outComeImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.outComeBg
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        view.addSubview(outComeImageView)
        
        return view
    }()
    
    lazy var outComeLabel: UILabel = {
        let label = UILabel()
        label.text = "지출"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }()
    
    lazy var outComeMoneyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    lazy var outComeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.outComeBg.withAlphaComponent(0.3)
        view.layer.cornerRadius = 10
        view.addSubview(outComeImageBackgroundView)
        view.addSubview(outComeLabel)
        view.addSubview(outComeMoneyLabel)
        
        return view
    }()
    
    lazy var moneyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [inComeView, outComeView])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
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
        
        self.contentView.addSubview(moneyStackView)
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
        
        // inCome 컴포넌트들
        inComeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        inComeImageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(30)
        }
        
        inComeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(inComeImageBackgroundView.snp.centerY)
            make.leading.equalTo(inComeImageBackgroundView.snp.trailing).offset(10)
        }
        
        inComeMoneyLabel.snp.makeConstraints { make in
            make.top.equalTo(inComeImageBackgroundView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        // outCome 컴포넌트들
        outComeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        outComeImageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(30)
        }
        
        outComeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(outComeImageBackgroundView.snp.centerY)
            make.leading.equalTo(outComeImageBackgroundView.snp.trailing).offset(10)
        }
        
        outComeMoneyLabel.snp.makeConstraints { make in
            make.top.equalTo(outComeImageBackgroundView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        // 스택뷰에 inCome, outCome 넣기
        moneyStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}
