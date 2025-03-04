//
//  StatisticViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit
import SnapKit
import Charts

class StatisticViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["일별", "주별", "월별"])
        segmentControl.selectedSegmentIndex = 2
        return segmentControl
    }()
    
    lazy var statisticTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(StatsTableViewCell.self, forCellReuseIdentifier: "StatsTableViewCell")
        tableView.register(BarChartTableViewCell.self, forCellReuseIdentifier: "BarChartTableViewCell")
        tableView.register(PieChartTableViewCell.self, forCellReuseIdentifier: "PieChartTableViewCell")
        tableView.register(InOutListTableViewCell.self, forCellReuseIdentifier: "InOutListTableViewCell")
        
        return tableView
    }()
    
    lazy var graphView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    lazy var categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var inOutView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    // 임시 데이터
    var inOutHeader: [String] = ["6일 월요일", "5일 일요일", "4일 토요일"]
    var inOutCell: [[InOutCellInfo]] = [
        [
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "+10", detailUse: "매일 용돈 받기"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "-3000", detailUse: "병원"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "+10", detailUse: "매일 용돈 받기"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "+10", detailUse: "매일 용돈 받기"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "+10", detailUse: "매일 용돈 받기")
        ],
        [
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "-32000", detailUse: "쿠팡"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "-36990", detailUse: "네이버페이"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "+15000", detailUse: "입금"),
        ],
        [
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "-4500", detailUse: "현대카드"),
            .init(transactionType: "지출", emoji: "\u{1F600}", money: "-52000", detailUse: "통신비")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticTableView.dataSource = self
        statisticTableView.delegate = self
        
        addSubViews()
        setLayout()
        
        self.reactor = StatisticReactor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("StatisticViewController - viewWillAppear() called")
//        reactor?.action.onNext(.fetchDbDataAction)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("StatisticViewController - viewWillDisappear() called")
        //        segmentControl.selectedSegmentIndex = 2
//        reactor?.action.onNext(.segmentControlIndexResetAction)
    }
}

extension StatisticViewController {
    
    func bind(reactor: StatisticReactor) {
        
        reactor.action.onNext(.fetchDbDataAction)
        
//        reactor.state
//            .map{$0.selectedIndex}
//            .distinctUntilChanged()
//            .subscribe { index in
//                print("index2:\(index)")
//                self.segmentControl.selectedSegmentIndex = index
//                reactor.action.onNext(.updateSegmentIndexAction(index))
//            }
//            .disposed(by: disposeBag)
        
        segmentControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .subscribe { index in
                self.segmentControl.selectedSegmentIndex = index
            reactor.action.onNext(.updateSegmentIndexAction(index))
        }
        .disposed(by: disposeBag)
        
        // 금액 변경, 막대 그래프 데이터 변경, 파이 그래프 데이터 변경되면 테이블 뷰 리로드
        reactor.state
            .map { ($0.outComeMoneyText, $0.inComeMoneyText, $0.barChartDatas, $0.pieChartDatas) }
            .distinctUntilChanged { $0 == $1 }
            .subscribe(onNext: { _ in
                print("테이블 뷰 리로드")
                self.statisticTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        statisticTableView.rx.willDisplayCell
            .compactMap { ($0.cell as? StatsTableViewCell) }
            .distinctUntilChanged()
            .subscribe { cell in
                cell.leftButtonTapped
                    .subscribe(onNext: {
                        print("왼쪽 버튼 탭")
                        reactor.action.onNext(.moveToDateAction(reactor.currentState.selectedDateCount - 1))
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.rightButtonTapped
                    .subscribe(onNext: {
                        print("오른쪽 버튼 탭")
                        reactor.action.onNext(.moveToDateAction(reactor.currentState.selectedDateCount + 1))
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
}

extension StatisticViewController {
    func addSubViews() {
        print("StatisticViewController - addSubViews() called")
        
        self.view.addSubview(statisticTableView)
    }
    
    func setLayout() {
        print("StatisticViewController - setLayout() called")
        
        let largeTitleLabel = UILabel()
        largeTitleLabel.text = "통계"
        largeTitleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        let leftItem = UIBarButtonItem(customView: largeTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentControl)
        
        self.view.backgroundColor = .systemGroupedBackground
        
        statisticTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension StatisticViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 + (reactor?.currentState.inOutDatas.keys.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0, 1, 2:
            return nil
            
        case 3...:
            if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                return headers[section - 3]
            }
                
            return nil
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2:
            return 1
            
        case 3...:
            if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                let key = headers[section - 3]
                return reactor?.currentState.inOutDatas[key]?.count ?? 0
            }
            
            return 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = StatisticSectionType(section: indexPath.section)
        
        switch sectionType {
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
            
            cell.dateLabel.text = reactor?.currentState.dateText ?? ""
            cell.withdrawMoneyLabel.text = reactor?.currentState.outComeMoneyText ?? ""
            cell.inComeMoneyLabel.text = reactor?.currentState.inComeMoneyText ?? "''"
            
            return cell
            
        case .barChart:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
            
            cell.previousSpendLabel.text = reactor?.currentState.lastSixMonthText ?? ""
            cell.barChartDatas = reactor?.currentState.barChartDatas ?? []

            return cell
            
        case .pieChart:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartTableViewCell", for: indexPath) as! PieChartTableViewCell
            
            cell.pieChartDatas = reactor?.currentState.pieChartDatas ?? []

            return cell
            
        case .inputList:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InOutListTableViewCell", for: indexPath) as! InOutListTableViewCell
            
            if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                let key = headers[indexPath.section - 3]
                if let inOutCell = reactor?.currentState.inOutDatas[key] {
                    cell.emojiLabel.text = inOutCell[indexPath.row].emoji
                    cell.moneyLabel.text = inOutCell[indexPath.row].money
                    cell.detailUseLabel.text = inOutCell[indexPath.row].detailUse
                }
            }
            
            return cell
        }
    }
}

extension StatisticViewController: UITableViewDelegate {
    
}
