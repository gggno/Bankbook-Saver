//
//  StatisticViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit

class StatisticViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "< 2024.12 >"
        return label
    }()
    
    lazy var inComeMoneyLabel: UILabel = {
        let label = UILabel()
        label.text = "0원"
        return label
    }()
    
    lazy var inComeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "총 수입"
        return label
    }()
    
    lazy var inComeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .green
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var withdrawMoneyLabel: UILabel = {
        let label = UILabel()
        label.text = "35000원"
        return label
    }()
    
    lazy var withdrawTextLabel: UILabel = {
        let label = UILabel()
        label.text = "총 수출"
        return label
    }()
    
    lazy var withdrawStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .cyan
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var littleMoneyTextLabel: UILabel = {
        let label = UILabel()
        label.text = "지난 달보다 30000원 덜 썼어요"
        return label
    }()
    
    lazy var graphView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    lazy var categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var inOutView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        setLayout()
        self.reactor = StatisticReactor()
    }
    
    func bind(reactor: StatisticReactor) {
        
    }
    
    
}

extension StatisticViewController {
    func addSubViews() {
        print("StatisticViewController - addSubViews() called")
        
        self.view.addSubview(dateLabel)
        
        inComeStackView.addArrangedSubview(inComeMoneyLabel)
        inComeStackView.addArrangedSubview(inComeTextLabel)
        self.view.addSubview(inComeStackView)
        
        withdrawStackView.addArrangedSubview(withdrawMoneyLabel)
        withdrawStackView.addArrangedSubview(withdrawTextLabel)
        self.view.addSubview(withdrawStackView)
        
        self.view.addSubview(littleMoneyTextLabel)
        
        self.view.addSubview(graphView)
        
        self.view.addSubview(categoryView)
        
        self.view.addSubview(inOutView)
    }
    
    func setLayout() {
        print("StatisticViewController - setLayout() called")
        
        self.view.backgroundColor = .systemGreen
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "윌별 v", style: .plain, target: nil, action: nil)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(self.view).offset(20)
        }
        
        inComeStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(dateLabel.snp.bottom).offset(30)
            make.leading.equalTo(self.view).offset(20)
        }
        
        withdrawStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(inComeStackView.snp.bottom).offset(30)
            make.leading.equalTo(self.view).offset(20)
        }
        
        littleMoneyTextLabel.snp.makeConstraints { make in
            make.top.equalTo(withdrawStackView.snp.bottom).offset(30)
            make.leading.equalTo(self.view).offset(20)
        }
        
        graphView.snp.makeConstraints { make in
            make.size.equalTo(250)
            make.centerX.equalTo(self.view)
            make.top.equalTo(littleMoneyTextLabel.snp.bottom).offset(30)
        }
        
        categoryView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(graphView.snp.bottom).offset(30)
            make.centerX.equalTo(self.view)
            make.leading.equalTo(self.view).offset(30)
        }
        
        // 수입/소비 테이블 뷰
        inOutView.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom).offset(50)
            make.leading.equalTo(self.view).offset(30)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
    }
}
