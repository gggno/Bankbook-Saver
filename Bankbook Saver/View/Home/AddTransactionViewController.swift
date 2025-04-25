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
        segmentControl.selectedSegmentTintColor = .outComeBg.withAlphaComponent(0.6)
        
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
        setUpKeyboard()

        addSubViews()
        setLayout()
        
        segmentControl.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        
        self.reactor = AddTransactionReactor()
    }
    
    // 지출/수입화면 변경
    @objc func didChangeValue(_ segment: UISegmentedControl) {
        print("AddTransactionViewController - didChangeValue() called")
        switch segmentControl.selectedSegmentIndex {
        case 0: // 지출
            self.expenseView.isHidden = false
            self.inComeView.isHidden = true
            addTransScrollView.isScrollEnabled = true
            addTransScrollView.showsVerticalScrollIndicator = true
            segment.selectedSegmentTintColor = .outComeBg.withAlphaComponent(0.6)
            
        case 1: // 수입
            self.expenseView.isHidden = true
            self.inComeView.isHidden = false
            addTransScrollView.isScrollEnabled = false
            addTransScrollView.showsVerticalScrollIndicator = false
            segment.selectedSegmentTintColor = .inComeBg.withAlphaComponent(0.6)
        
        default:
            self.expenseView.isHidden = false
            self.inComeView.isHidden = true
            addTransScrollView.isScrollEnabled = true
            addTransScrollView.showsVerticalScrollIndicator = true
            segment.selectedSegmentTintColor = .outComeBg.withAlphaComponent(0.6)
            
        }
    }
    
    // 거래 내역 삭제하기
    func deleteTransactionData() {
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(deleteAlert))
        
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
    
    func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        // keyboardFrame : 현재 동작하고 있는 이벤트에서 키보드의 frame을 받아옴
        // currentTextField : 현재 응답을 받고 있는 UITextField를 확인한다.
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let currentTextField = UIResponder.currentResponder as? UITextField else { return }
        
        // keyboardYTop : 키보드 상단의 y값(=높이)
        let keyboardYTop = keyboardFrame.cgRectValue.origin.y
        // convertedTextFieldFrame : 현재 선택한 textField의 frame값(=CGRect). superview에서 frame으로 convert를 했다는데.. 무슨 말인지..
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        // textFieldYBottom : 텍스트필드 하단의 y값 = 텍스트필드의 y값(=y축 위치) + 텍스트필드의 높이
        let textFieldYBottom = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // textField 하단의 y축 값이 키보드 상단의 y축 값보다 클 때(키보드가 textField를 침범할 때)
        if textFieldYBottom > keyboardYTop {
            let textFieldYTop = convertedTextFieldFrame.origin.y
            let properTextFieldHight = textFieldYTop - keyboardYTop/1.3
            // view의 위치를 변경
            view.frame.origin.y = -properTextFieldHight
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func confirmAlert() {
        print("AddTransactionViewController - confirmAlert() called")
        
        let alert = UIAlertController(title: "거래 내역 저장",
                                      message: "거래 내역을 저장하였습니다.",
                                      preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "확인",
                                       style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(doneAction)
        
        self.present(alert, animated: true)
    }
    
    @objc func deleteAlert() {
        print("AddTransactionViewController - deleteAlert() called")
        
        let alert = UIAlertController(title: "거래 내역 삭제",
                                      message: "거래 내역을 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제",
                                       style: .destructive) { action in
            self.deleteTransactionData()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancleAction = UIAlertAction(title: "취소",
                                         style: .default) { action in
          }
        
        alert.addAction(deleteAction)
        alert.addAction(cancleAction)
        
        self.present(alert, animated: true)
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
                // 확인 알림 창 띄우기
                self.confirmAlert()
            }
            .disposed(by: disposeBag)
        
        inComeView.confirmButton.rx.tap
            .subscribe { _ in
                // 등록한 지출/수입을 수정할 때 기존에 저장된 데이터는 삭제(realm에서 삭제, 정기 알림도 삭제)
                reactor.action.onNext(.removeExistDataAction(self.transactionId))
                // realm에 입력한 수입 데이터 저장
                reactor.action.onNext(.addHomeDataAction)
                // 확인 알림 창 띄우기
                self.confirmAlert()
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
        
        // 확인 버튼 활성화/비활성화
        Observable.combineLatest(
            expenseView.moneyInputFieldView.textField.rx.text.orEmpty,
            expenseView.expensePurposeInputFieldView.textField.rx.text.orEmpty)
        .map { money, purpose in
            return !money.isEmpty && !purpose.isEmpty
        }
        .subscribe(onNext: { isValid in
            self.expenseView.confirmButton.isEnabled = isValid
            self.expenseView.confirmButton.backgroundColor = isValid ? .label : .gray
        })
        .disposed(by: disposeBag)
        
        Observable.combineLatest(
            inComeView.moneyInputFieldView.textField.rx.text.orEmpty,
            inComeView.incomePurposeInputFieldView.textField.rx.text.orEmpty)
        .map { money, purpose in
            return !money.isEmpty && !purpose.isEmpty
        }
        .subscribe(onNext: { isValid in
            self.inComeView.confirmButton.isEnabled = isValid
            self.inComeView.confirmButton.backgroundColor = isValid ? .label : .gray
        })
        .disposed(by: disposeBag)
    }
}
