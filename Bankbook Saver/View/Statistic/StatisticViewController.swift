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
    
    func bind(reactor: StatisticReactor) {
        
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
        return 3 + inOutHeader.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0, 1, 2:
            return nil
            
        case 3...:
            return inOutHeader[section-3]
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2:
            return 1
            
        case 3...:
            return inOutCell[section-3].count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = StatisticSectionType(section: indexPath.section)
        
        switch sectionType {
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
            
            return cell
            
        case .barChart:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
            
            return cell
            
        case .pieChart:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartTableViewCell", for: indexPath) as! PieChartTableViewCell
            
            return cell
            
        case .inputList:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InOutListTableViewCell", for: indexPath) as! InOutListTableViewCell
            let section = indexPath.section - 3
            
            cell.emojiLabel.text = inOutCell[section][indexPath.row].emoji
            cell.moneyLabel.text = inOutCell[section][indexPath.row].money
            cell.detailUseLabel.text = inOutCell[section][indexPath.row].detailUse
            
            return cell
        }
    }
}

extension StatisticViewController: UITableViewDelegate {
    
}
