//
//  DarkLightSettingViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/19/25.
//

import UIKit
import SnapKit
import ReactorKit

class DarkLightSettingViewController: UIViewController {
    
    lazy var displayModeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(DisplayModeTableViewCell.self, forCellReuseIdentifier: "DisplayModeTableViewCell")
        return tableView
    }()
    
    var disposeBag: DisposeBag = DisposeBag()

    init(reactor: DarkLightReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "다크/라이트모드 설정"
        self.view.backgroundColor = .systemGroupedBackground
        
        self.displayModeTableView.dataSource = self
        self.displayModeTableView.delegate = self
        
        self.addSubViews()
        self.setLayout()
    }
}

// MARK: UI
extension DarkLightSettingViewController {
    func addSubViews() {
        print("DarkLightSettingViewController - addSubViews() called")
        self.view.addSubview(displayModeTableView)
    }
    
    func setLayout() {
        print("DarkLightSettingViewController - setLayout() called")
        displayModeTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension DarkLightSettingViewController: View {
    func bind(reactor: DarkLightReactor) {
        // Action - trigger
        
        // State - binding
    }
}

// MARK: TableView - UITableViewDataSource
extension DarkLightSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowIntType = DisplayRowIntType(rawValue: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayModeTableViewCell", for: indexPath) as! DisplayModeTableViewCell
        
        cell.selectionStyle = .none
        
        switch rowIntType {
        case .dark:
            cell.modeLabel.text = "다크 모드"
        case .light:
            cell.modeLabel.text = "라이트 모드"
        case .system:
            cell.modeLabel.text = "시스템 설정과 같이"
        default:
            break
        }
         
        if let reactor = self.reactor, reactor.myPageReactor.currentState.displayIntType == rowIntType?.rawValue {
            cell.checkImageView.image = UIImage(systemName: "checkmark")
        } else {
            cell.checkImageView.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowIntType = DisplayRowIntType(rawValue: indexPath.row) else {return}
        
        switch rowIntType {
        case .dark:
            reactor?.action.onNext(.updateMyPageDisplayModeAction(DisplayType.dark.rawValue))
        case .light:
            reactor?.action.onNext(.updateMyPageDisplayModeAction(DisplayType.light.rawValue))
        case .system:
            reactor?.action.onNext(.updateMyPageDisplayModeAction(DisplayType.system.rawValue))
        }
        
        tableView.reloadData()
    }
    
}

// MARK: TableView - UITableViewDelegate
extension DarkLightSettingViewController: UITableViewDelegate {
    
}
