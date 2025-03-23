//
//  InComeView.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/10/25.
//

import UIKit
import SnapKit
import RxSwift

class InComeView: UIView {
    
    let categories = InComeCategoryType.allCases
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    let incomeSelectedDate = BehaviorSubject<Date>(value: Date())
    let selectedCategoryIndex = PublishSubject<Int>()
    
    lazy var moneyInputFieldView: InputFieldView = {
        let view = InputFieldView(title: "금액을 입력하세요", placeholder: "금액을 입력하세요", keyboardType: .numberPad, unitText: "원")
        return view
    }()
    
    lazy var incomePurposeInputFieldView: InputFieldView = {
        let view = InputFieldView(title: "수입처를 입력하세요", placeholder: "수입처를 입력하세요")
        return view
    }()
    
    lazy var payDayView: PayDayView = {
        let view = PayDayView(payTypeText: "수입일시", dateText: "2월 5일 16:39")
        view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(payDayViewTap))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    lazy var hiddenTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = .clear
        textField.inputView = datePicker
        textField.inputAccessoryView = toolBar
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "ko_KR")
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissPicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton], animated: false)
        return toolBar
    }()
    
    lazy var repeatStateLabel: UILabel = {
        let label = UILabel()
        label.text = "매월 수입으로 등록"
        return label
    }()
    
    lazy var repeatState: UISwitch = {
        let repeatSwitch = UISwitch()
        
        repeatSwitch.addTarget(self, action: #selector(switchToggle(_:)), for: .valueChanged)
        return repeatSwitch
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        return label
    }()
    
    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .secondarySystemGroupedBackground
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        
        return collectionView
    }()
    
    lazy var memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var memoTextField: UITextField = {
        let textField = UITextField()
        textField.inputAccessoryView = memoToolbar
        textField.placeholder = "메모를 입력하세요"
        return textField
    }()
    
    lazy var memoToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(memoDismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        return toolbar
    }()
    
    lazy var memoUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
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
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubViews() {
        self.addSubview(moneyInputFieldView)
        
        self.addSubview(incomePurposeInputFieldView)
        
        self.addSubview(payDayView)
        self.addSubview(hiddenTextField)
        
        self.addSubview(repeatStateLabel)
        self.addSubview(repeatState)
        
        self.addSubview(categoryLabel)
        self.addSubview(categoryCollectionView)
        
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
        
        incomePurposeInputFieldView.snp.makeConstraints { make in
            make.top.equalTo(moneyInputFieldView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        payDayView.snp.makeConstraints { make in
            make.top.equalTo(incomePurposeInputFieldView.snp.bottom).offset(30)
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
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(repeatState.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            // (UIScreen.main.bounds.width - 100 - 20) / 4 -> 하나의 셀 높이
            // minimumLineSpacing(30) -> 세로의 셀 간격
            make.height.equalTo(((UIScreen.main.bounds.width - 100 - 20) / 4) + 20)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        memoTextField.snp.makeConstraints { make in
            make.height.equalTo(45)
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
            
            // make.bottom.equalToSuperview()   // 스크롤뷰 높이 때문에 마지막 UI가 바텀 앵커 걸어야함(수입 뷰는 스크롤 비활 땜에 주석)
        }
        
    }
    
    // 지출일시 탭
    @objc func payDayViewTap(_ sender: UITapGestureRecognizer) {
        hiddenTextField.becomeFirstResponder()
    }
    
    // 지출일시 날짜 변경하기
    @objc func dateChanged(_ sender: UIDatePicker) {
        
    }
    
    // 데이트픽커 내리기
    @objc func dismissPicker() {
        hiddenTextField.resignFirstResponder()
        incomeSelectedDate.onNext(datePicker.date)
    }
    
    // 메모 키보드 내리기
    @objc func memoDismissKeyboard() {
        memoTextField.resignFirstResponder()
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

extension InComeView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        //        cell.backgroundColor = .brown
        cell.emijiLabel.text = categories[indexPath.row].emoji
        cell.nameLabel.text = categories[indexPath.row].title
        
        if indexPath == selectedIndexPath {
            cell.backgroundColor = .gray
            selectedCategoryIndex.onNext(indexPath.row)
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        categoryCollectionView.reloadData()
    }
}

extension InComeView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 60: minimumInteritemSpacing의 개수(고정)
        // 20: leading(10), trailing(20)의 EdgeInset(고정)
        let width = (UIScreen.main.bounds.width - 100 - 20) / 4
        
        return CGSize(width: width, height: width)
    }
}
