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
    var sectionCell: [[MypageCellInfo]] = [[MypageCellInfo(title: "위시리스트",
                                                           rightImage: UIImage(systemName: "chevron.right")),
                                            MypageCellInfo(title: "다크/라이트모드 설정",
                                                           rightImage: UIImage(systemName: "chevron.right"),
                                                           rightImageText: "시스템")],
                                           
                                           [MypageCellInfo(title: "알림 설정",
                                                           rightImage: UIImage(systemName: "chevron.right"))],
                                           
                                           [MypageCellInfo(title: "계좌 관리",
                                                           rightImage: UIImage(systemName: "chevron.right"))],
                                           
                                           [MypageCellInfo(title: "별점 선물하기"),
                                            MypageCellInfo(title: "앱 버전",
                                                           rightText: "v1.0.0")]
    ]
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let largeTitleLabel = UILabel()
        largeTitleLabel.text = "마이페이지"
        largeTitleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        let leftItem = UIBarButtonItem(customView: largeTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
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
        
        cell.title.text = sectionCell[indexPath.section][indexPath.row].title
        cell.rightImage.image = sectionCell[indexPath.section][indexPath.row].rightImage
        cell.rightImageText.text = sectionCell[indexPath.section][indexPath.row].rightImageText
        cell.rightText.text = sectionCell[indexPath.section][indexPath.row].rightText
        
        return cell
    }
}

extension MypageViewController: UITableViewDelegate {
    
}
