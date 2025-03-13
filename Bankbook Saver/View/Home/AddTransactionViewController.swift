//
//  AddTransactionViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/5/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class AddTransactionViewController: UIViewController {
    
    var transactionId: String?
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["지출", "수입"])
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    lazy var expenseView: ExpenseView = {
        let view = ExpenseView()
        
        return view
    }()
    
    lazy var inComeView: InComeView = {
        let view = InComeView()
        
        return view
    }()
    
    lazy var addTransScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddTransactionViewController - viewDidLoad() called")
        
        self.view.backgroundColor = .systemGroupedBackground
        self.title = "거래 내역 추가하기"
        
        addSubViews()
        setLayout()
        
        segmentControl.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        
        self.reactor = AddTransactionReactor()
    }
    
    // 지출/수입화면 변경
    @objc func didChangeValue(_ segment: UISegmentedControl) {
        print("AddTransactionViewController - didChangeValue() called")
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.expenseView.isHidden = false
            self.inComeView.isHidden = true
        case 1:
            self.expenseView.isHidden = true
            self.inComeView.isHidden = false
            
        default:
            self.expenseView.isHidden = false
            self.inComeView.isHidden = true
        }
    }
    
    // 거래 내역 삭제하기
    @objc func deleteTransactionData() {
        print("AddTransactionViewController - deleteTransactionData() called")
        reactor?.action.onNext(.removeExistDataAction(self.transactionId))
    }
     
}

// MARK: - UI
extension AddTransactionViewController {
    func addSubViews() {
        print("AddTransactionViewController - addSubViews() called")
        
        self.view.addSubview(addTransScrollView)
        
        addTransScrollView.addSubview(backgroundView)
        
        backgroundView.addSubview(segmentControl)
        backgroundView.addSubview(expenseView)
        backgroundView.addSubview(inComeView)
        
    }
    
    func setLayout() {
        print("AddTransactionViewController - setLayout() called")
        
        // 오른쪽 상단 삭제 버튼
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(deleteTransactionData))
        
        // 수정하기가 아니면 삭제 버튼 히든
        if transactionId != nil {
            self.navigationItem.rightBarButtonItem?.isHidden = false
        } else {
            self.navigationItem.rightBarButtonItem?.isHidden = true
        }
            
        addTransScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(addTransScrollView.contentLayoutGuide.snp.top)
            make.bottom.equalTo(addTransScrollView.contentLayoutGuide.snp.bottom)
            make.leading.equalTo(addTransScrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(addTransScrollView.contentLayoutGuide.snp.trailing)
            make.width.equalTo(addTransScrollView.snp.width)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        //지출 뷰
        expenseView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        // 수입 뷰
        inComeView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension AddTransactionViewController: View {
    func bind(reactor: AddTransactionReactor) {
        
        // 거래 내역 타입
        segmentControl.rx.selectedSegmentIndex
            .map{$0 == 0 ? "지출" : "수입"}
            .map{.updateTransactionTypeAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 금액 입력
        expenseView.moneyInputFieldView.textField.rx.text
            .orEmpty
            .map { .updateMoneyTextAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inComeView.moneyInputFieldView.textField.rx.text
            .orEmpty
            .map { .updateMoneyTextAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 지출/수입처 입력
        expenseView.expensePurposeInputFieldView.textField.rx.text
            .orEmpty
            .map{ .updatePurposeTextAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inComeView.incomePurposeInputFieldView.textField.rx.text
            .orEmpty
            .map{ .updatePurposeTextAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 일시
        expenseView.expenseSelectedDate.subscribe { selectedDate in
            print("expenseView.selectedDate.subscribe")
            reactor.action.onNext(.updatePurposeDateAction(selectedDate))
        }
        .disposed(by: disposeBag)
        
        inComeView.incomeSelectedDate.subscribe { selectedDate in
            print("inComeView.selectedDate.subscribe")
            reactor.action.onNext(.updatePurposeDateAction(selectedDate))
        }
        .disposed(by: disposeBag)
        
        // 매월 반복
        expenseView.repeatState.rx.isOn
            .map{.repeatStateAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inComeView.repeatState.rx.isOn
            .map{.repeatStateAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 지출수단
        expenseView.typeSegmentControl.rx.selectedSegmentIndex
            .map{.expenseKindAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 카테고리
        expenseView.selectedCategoryIndex.subscribe { selectedIndex in
            reactor.action.onNext(.updateCategoryIndexAction(selectedIndex))
        }
        .disposed(by: disposeBag)
         
        inComeView.selectedCategoryIndex.subscribe { selectedIndex in
            reactor.action.onNext(.updateCategoryIndexAction(selectedIndex))
        }
        .disposed(by: disposeBag)
        
        
        // 메모 입력
        expenseView.memoTextField.rx.text
            .orEmpty
            .map{.updateMemoTextAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inComeView.memoTextField.rx.text
            .orEmpty
            .map{.updateMemoTextAction($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 확인 버튼 탭
        expenseView.confirmButton.rx.tap
            .subscribe { _ in
                // 등록한 지출/수입을 수정할 때 기존에 저장된 데이터는 삭제(realm에서 삭제, 정기 알림도 삭제)
                reactor.action.onNext(.removeExistDataAction(self.transactionId))
                // realm에 입력한 지출 데이터 저장
                reactor.action.onNext(.addHomeDataAction)
            }
            .disposed(by: disposeBag)
        
        inComeView.confirmButton.rx.tap
            .subscribe { _ in
                // 등록한 지출/수입을 수정할 때 기존에 저장된 데이터는 삭제(realm에서 삭제, 정기 알림도 삭제)
                reactor.action.onNext(.removeExistDataAction(self.transactionId))
                // realm에 입력한 수입 데이터 저장
                reactor.action.onNext(.addHomeDataAction)
            }
            .disposed(by: disposeBag)
        
        
        // 바인딩
        reactor.state
            .map { state in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "M월 d일 HH:mm"
                return formatter.string(from: state.purposeDate)
            }
            .bind(to: self.expenseView.payDayView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "M월 d일 HH:mm"
                return formatter.string(from: state.purposeDate)
            }
            .bind(to: self.inComeView.payDayView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.purposeDate}
            .bind(to: expenseView.datePicker.rx.date)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.purposeDate }
            .bind(to: inComeView.datePicker.rx.date)
            .disposed(by: disposeBag)
    }
}
