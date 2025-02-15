//
//  HomeViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
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
        tableView.estimatedRowHeight = 300
        
        tableView.register(HomeCalenderTableViewCell.self, forCellReuseIdentifier: "HomeCalenderTableViewCell")
        //        tableView.register(SelectedInOutTableViewCell.self, forCellReuseIdentifier: "SelectedInOutTableViewCell")
        tableView.register(InOutListTableViewCell.self, forCellReuseIdentifier: "InOutListTableViewCell")
        return tableView
    }()
    
    // 임시 데이터
    var inOutHeader: [String] = ["6일 월요일", "5일 일요일", "4일 토요일"]
    var inOutCell: [[InOutCellInfo]] = [
        [
            .init(emoji: "\u{1F600}", money: "+10", detailUse: "매일 용돈 받기"),
            .init(emoji: "\u{1F600}", money: "-3000", detailUse: "병원"),
            .init(emoji: "\u{1F600}", money: "-7600", detailUse: "약국"),
            .init(emoji: "\u{1F600}", money: "+10", detailUse: "매일 혜택 받기"),
        ],
        [
            .init(emoji: "\u{1F600}", money: "-32000", detailUse: "쿠팡"),
            .init(emoji: "\u{1F600}", money: "-36990", detailUse: "네이버페이"),
            .init(emoji: "\u{1F600}", money: "+15000", detailUse: "입금"),
        ],
        [
            .init(emoji: "\u{1F600}", money: "-4500", detailUse: "현대카드"),
            .init(emoji: "\u{1F600}", money: "-52000", detailUse: "통신비")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        // UI 설정
        addSubViews()
        setLayout()
        
        self.reactor = HomeReactor()
        
        
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

extension HomeViewController: View {
    func bind(reactor: HomeReactor) {
        // 처음에 날짜 가져오기(초기값 0)
        reactor.action.onNext(.fetchDateAction(count: 0))
        
        // 이전 달 또는 다음 달 날짜 가져오기
        homeTableView.rx.willDisplayCell
            .compactMap { ($0.cell as? HomeCalenderTableViewCell) }
            .distinctUntilChanged()
            .subscribe { cell in
                cell.lastMonthButtonTapped
                    .subscribe(onNext: {
                        print("이전 달 버튼 탭 감지")
                        reactor.action.onNext(.fetchDateAction(count: -1))
                        cell.dayValue = reactor.currentState.selectedDays
                        cell.calendarCollectionView.reloadData()
                        self.homeTableView.reloadData()
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.nextMonthButtonTapped
                    .subscribe(onNext: {
                        print("다음 달 버튼 탭 감지")
                        reactor.action.onNext(.fetchDateAction(count: 1))
                        cell.dayValue = reactor.currentState.selectedDays
                        cell.calendarCollectionView.reloadData()
                        self.homeTableView.reloadData()
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 거래내역 화면으로 이동
        floatingButton.rx.tap
            .subscribe { _ in
                let addVC = AddTransactionViewController()
                self.navigationController?.pushViewController(addVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + inOutHeader.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
            
        case 1...:
            return inOutHeader[section-1]
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1...:
            return inOutCell[section-1].count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = HomeSectionType(section: indexPath.section)
        
        switch sectionType {
        case .homeCalendar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCalenderTableViewCell", for: indexPath) as! HomeCalenderTableViewCell
            
            cell.monthLabel.text = self.reactor?.currentState.selectedMonth
            
            let days = self.reactor?.currentState.selectedDays ?? []
            cell.dayValue = days
            
            // 날짜 개수에 따라 줄 개수 구하는 계산식
            if days.count % 7 == 0 {
                cell.updateCollectionViewHeight(lineCnt: days.count / 7)
            } else {
                cell.updateCollectionViewHeight(lineCnt: (days.count / 7) + 1)
            }
            
            return cell
            
        case .homeInOutList:
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedInOutTableViewCell", for: indexPath) as! SelectedInOutTableViewCell
            //            return cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "InOutListTableViewCell", for: indexPath) as! InOutListTableViewCell
            let section = indexPath.section - 1
            
            cell.emojiLabel.text = inOutCell[section][indexPath.row].emoji
            cell.moneyLabel.text = inOutCell[section][indexPath.row].money
            cell.detailUseLabel.text = inOutCell[section][indexPath.row].detailUse
            
            return cell
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
}
