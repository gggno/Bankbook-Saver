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
    
    lazy var floatingButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    lazy var homeTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(HomeCalenderTableViewCell.self, forCellReuseIdentifier: "HomeCalenderTableViewCell")
        tableView.register(SelectedInOutTableViewCell.self, forCellReuseIdentifier: "SelectedInOutTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
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
        
        self.view.addSubview(homeTableView)
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
        
        // 플로팅 버튼
        floatingButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailing.equalTo(self.view).offset(-15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
        }
        
        homeTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return 1    // 수정 필요
        
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCalenderTableViewCell", for: indexPath) as! HomeCalenderTableViewCell
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedInOutTableViewCell", for: indexPath) as! SelectedInOutTableViewCell
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
}
