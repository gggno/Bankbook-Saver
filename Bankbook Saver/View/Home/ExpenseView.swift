//
//  ExpenseView.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/6/25.
//

import UIKit
import SnapKit

class ExpenseView: UIView {
    
    lazy var moneyInputFieldView: UIView = {
        let view = InputFieldView(title: "금액을 입력하세요", placeholder: "금액을 입력하세요", unitText: "원")
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var expensePurposeInputFieldView: UIView = {
        let view = InputFieldView(title: "지출처를 입력하세요", placeholder: "지출처를 입력하세요")
        return view
    }()
    
    lazy var payDayView: UIView = {
        let view = PayDayView(payTypeText: "지출일시", dateText: "2월 5일 16:39")
        view.backgroundColor = .red
        view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(payDayViewTap))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    lazy var repeatStateLabel: UILabel = {
        let label = UILabel()
        label.text = "매월 지출로 등록"
        return label
    }()
    
    lazy var repeatState: UISwitch = {
        let repeatSwitch = UISwitch()
        
        repeatSwitch.addTarget(self, action: #selector(switchToggle(_:)), for: .valueChanged)
        return repeatSwitch
    }()
    
    lazy var typeSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["신용카드", "체크카드", "현금", "계좌이체"])
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        return label
    }()
    
    // 카테고리 목록들 나오게 수정해야 함.
    lazy var tempCategoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    lazy var memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var memoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메모를 입력하세요"
        textField.backgroundColor = .brown
        return textField
    }()
    
    lazy var memoUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubViews() {
        self.addSubview(moneyInputFieldView)
        
        self.addSubview(expensePurposeInputFieldView)
        
        self.addSubview(payDayView)
        
        self.addSubview(repeatStateLabel)
        self.addSubview(repeatState)
        
        self.addSubview(typeSegmentControl)
        
        self.addSubview(categoryLabel)
        self.addSubview(tempCategoryView)
        
        self.addSubview(memoLabel)
        self.addSubview(memoTextField)
        self.addSubview(memoUnderlineView)
        
        self.addSubview(confirmButton)
    }
    
    func setLayout() {
        moneyInputFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        expensePurposeInputFieldView.snp.makeConstraints { make in
            make.top.equalTo(moneyInputFieldView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        payDayView.snp.makeConstraints { make in
            make.top.equalTo(expensePurposeInputFieldView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(40)
        }
        
        repeatStateLabel.snp.makeConstraints { make in
            make.top.equalTo(payDayView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
//            make.height.equalTo(40)
        }
        
        repeatState.snp.makeConstraints { make in
            make.top.equalTo(payDayView.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(40)
        }
        
        typeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(repeatState.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentControl.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        tempCategoryView.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.top.equalTo(categoryLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(tempCategoryView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        memoTextField.snp.makeConstraints { make in
//            make.height.equalTo(50)
            make.top.equalTo(memoLabel.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        memoUnderlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(memoTextField.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(memoUnderlineView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalToSuperview().offset(-20)
            
            make.bottom.equalToSuperview()   // 스크롤뷰 높이 때문에 마지막 UI가 바텀 앵커 걸어야함
        }
    }
    
    @objc func payDayViewTap() {
        print("payDayView tapped!")
        
    }
    
    @objc func switchToggle(_ sender: UISwitch) {
        print("switchToggle")
        
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
}
