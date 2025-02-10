//
//  AddTransactionViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/5/25.
//

import UIKit
import SnapKit

class AddTransactionViewController: UIViewController {
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["지출", "수입"])
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    lazy var expenseView: UIView = {
        let view = ExpenseView()
        
        return view
    }()
    
    lazy var inComeView: UIView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemYellow
        self.title = "거래 내역 추가하기"
        
        addSubViews()
        setLayout()
        
        // 처음에는 지출 화면 나타나게 하기
        expenseView.isHidden = false
        inComeView.isHidden = true
        
        segmentControl.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
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
}
