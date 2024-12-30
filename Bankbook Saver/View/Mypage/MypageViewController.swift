//
//  MypageViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit
import SnapKit

class MypageViewController: UIViewController, View {
    
    lazy var myPageTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(MypageTableViewCell.self, forCellReuseIdentifier: "MypageTableViewCell")
        return tableView
    }()
    
    // 임시 데이터
    var sectionHeader: [String] = ["일반", "알림", "저축 관리", "기타"]
    var sectionCell: [[String]] = [["위시리스트", "다크/라이트모드 설정"], ["알림 설정"], ["계좌 관리"], ["앱 공유하기", "별점 선물하기", "앱 버전"]]
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let largeTitleLabel = UILabel()
        largeTitleLabel.text = "마이페이지"
        largeTitleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        largeTitleLabel.textColor = .black
        
        let leftItem = UIBarButtonItem(customView: largeTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        myPageTableView.dataSource = self
        myPageTableView.delegate = self
        
        addSubViews()
        setLayout()
        self.reactor = MypageReactor()
    }
    
    func bind(reactor: MypageReactor) {
        
    }
    
}

// UI
extension MypageViewController {
    
    func addSubViews() {
        print("MypageViewController - addSubViews() called")
        self.view.addSubview(myPageTableView)
    }
    
    func setLayout() {
        print("MypageViewController - setLayout() called")
                
        myPageTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MypageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeader.count
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCell[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MypageTableViewCell", for: indexPath) as! MypageTableViewCell
        cell.menuLabel.text = sectionCell[indexPath.section][indexPath.row]
        
        return cell
    }
}

extension MypageViewController: UITableViewDelegate {
    
}
