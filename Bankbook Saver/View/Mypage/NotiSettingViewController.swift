//
//  NotiSettingViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/19/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class NotiSettingViewController: UIViewController {
    
    lazy var notiSettingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(NotiSettingTableViewCell.self, forCellReuseIdentifier: "NotiSettingTableViewCell")
        return tableView
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "알림 설정"
        self.view.backgroundColor = .systemGroupedBackground
        
        self.notiSettingTableView.dataSource = self
        self.notiSettingTableView.delegate = self
        
        addSubViews()
        setLayout()
        
        self.reactor = NotiSettingReactor()
    }
}

// MARK: UI
extension NotiSettingViewController {
    func addSubViews() {
        print("NotiSettingViewController - addSubViews() called")
        self.view.addSubview(notiSettingTableView)
    }
    
    func setLayout() {
        print("NotiSettingViewController - setLayout() called")
        notiSettingTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NotiSettingViewController: View {
    func bind(reactor: NotiSettingReactor) {
        
        // 매일 알림이 로컬에 존재하는지 여부 전달 후 토글 상태 업데이트
        LocalNotiManager.shared.dailyReminderExists { state in
            reactor.action.onNext(.dailyReminderExistsAction(state))
        }
        
        notiSettingTableView.rx.willDisplayCell
            .compactMap { ($0.cell as? NotiSettingTableViewCell, $0.indexPath) }
            .subscribe(onNext: { (cell, indexPath) in
                guard let cell = cell else { return }
                
                // 알림 허용/미허용 스위치 상태 변경 감지
                cell.notiSwitchState
                    .subscribe { state in
                        switch indexPath.row {
                        case 0: // 매일 알림
                            reactor.action.onNext(.dailyReminderAction(state))
                            
                        default:
                            break
                        }
                    }
                    .disposed(by: cell.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: TableView - UITableViewDataSource
extension NotiSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactor?.currentState.cellInfo.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotiSettingTableViewCell", for: indexPath) as! NotiSettingTableViewCell
        
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0: // 매일 가게부 작성 알림
            cell.titleLabel.text = reactor?.currentState.cellInfo[indexPath.row].title
            cell.subTitleLabel.text = reactor?.currentState.cellInfo[indexPath.row].subTitle
            cell.notiSwitch.isOn = reactor?.currentState.cellInfo[indexPath.row].state ?? false
            
        default:
            break
        }
        
        cell.titleLabel.text = reactor?.currentState.cellInfo[indexPath.row].title
        cell.subTitleLabel.text = reactor?.currentState.cellInfo[indexPath.row].subTitle
        cell.notiSwitch.isOn = reactor?.currentState.cellInfo[indexPath.row].state ?? false
        
        return cell
    }
    
}

// MARK: TableView - UITableViewDelegate
extension NotiSettingViewController: UITableViewDelegate {
    
}
