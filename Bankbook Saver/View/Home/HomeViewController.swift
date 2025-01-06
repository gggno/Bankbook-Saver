//
//  HomeViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit
import SnapKit

class HomeViewController: UIViewController, View {

    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var calendarView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var inOutView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var floatingButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI 설정
        addSubViews()
        setLayout()
        
        self.reactor = HomeReactor()
    }
    
    func bind(reactor: HomeReactor) {
        
    }
    
}

// UI
extension HomeViewController {
    func addSubViews() {
        print("HomeViewController - addSubViews() called")
        
        self.view.addSubview(calendarView)      // 캘린더 뷰
        self.view.addSubview(inOutView)       // 수입/소비 테이블 뷰
        self.view.addSubview(floatingButton)    // 플로팅 버튼
    }
    
    // 레이아웃 설정
    func setLayout() {
        print("HomeViewController - setLayout() called")
        
        let leftLargeTitleLabel = UILabel()
        leftLargeTitleLabel.text = "홈"
        leftLargeTitleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        let leftTitle = UIBarButtonItem(customView: leftLargeTitleLabel)
        self.navigationItem.leftBarButtonItem = leftTitle
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        
        self.view.backgroundColor = .systemGroupedBackground
        
        // 캘린더 뷰
        calendarView.snp.makeConstraints { make in
            make.height.equalTo(350)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(0)
            make.leading.equalTo(self.view).offset(15)
            make.centerX.equalTo(self.view)
        }
        
        // 수입/소비 테이블 뷰
        inOutView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(50)
            make.leading.equalTo(self.view).offset(15)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        // 플로팅 버튼
        floatingButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailing.equalTo(self.view).offset(-15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
        } 
    }
}
