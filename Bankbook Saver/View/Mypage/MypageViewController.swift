//
//  MypageViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit
import SnapKit

class MypageViewController: UIViewController {
    
    lazy var myPageTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(MypageTableViewCell.self, forCellReuseIdentifier: "MypageTableViewCell")
        return tableView
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPageTableView.dataSource = self
        myPageTableView.delegate = self
        
        addSubViews()
        setLayout()
        self.reactor = MypageReactor()
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

extension MypageViewController: View {
    func bind(reactor: MypageReactor) {
        
        // 현재 버전 가져오기
        reactor.action.onNext(.getCurrentVersionAction)
        
    }
}

extension MypageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.reactor?.currentState.myPageHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reactor?.currentState.myPageRow[section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MypageTableViewCell", for: indexPath) as! MypageTableViewCell
        
        cell.selectionStyle = .none
        
        cell.title.text = self.reactor?.currentState.myPageRow[indexPath.section][indexPath.row].title
        cell.rightImage.image = UIImage(systemName: self.reactor?.currentState.myPageRow[indexPath.section][indexPath.row].rightImageName ?? "")
        cell.rightImageText.text = self.reactor?.currentState.myPageRow[indexPath.section][indexPath.row].rightImageText
        cell.rightText.text = self.reactor?.currentState.myPageRow[indexPath.section][indexPath.row].rightText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let wishVC = WishListViewController()
                self.navigationController?.pushViewController(wishVC, animated: true)

            } else if indexPath.row == 1 {
                let darkLightSettingVC = DarkLightSettingViewController()
                self.navigationController?.pushViewController(darkLightSettingVC, animated: true)
            }
            
        case 1:
            let notiSettingVC = NotiSettingViewController()
            self.navigationController?.pushViewController(notiSettingVC, animated: true)
            
        case 2:
            let accountVC = AccountViewController()
            self.navigationController?.pushViewController(accountVC, animated: true)
            
        default:
            break
        }
    }
    
}

extension MypageViewController: UITableViewDelegate {
    
}
