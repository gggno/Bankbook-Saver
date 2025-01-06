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
        
//        self.view.addSubview(dateLabel)
//        
//        self.view.addSubview(leftMoveButton)
//        
//        self.view.addSubview(rightMoveButton)
//        
//        inComeStackView.addArrangedSubview(inComeMoneyLabel)
//        inComeStackView.addArrangedSubview(inComeTextLabel)
//        self.view.addSubview(inComeStackView)
//        
//        withdrawStackView.addArrangedSubview(withdrawMoneyLabel)
//        withdrawStackView.addArrangedSubview(withdrawTextLabel)
//        self.view.addSubview(withdrawStackView)
        
//        self.view.addSubview(littleMoneyTextLabel)
        
        self.view.addSubview(graphView)
        
        self.view.addSubview(categoryView)
        
        self.view.addSubview(inOutView)
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
        
//        dateLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
//            make.leading.equalTo(self.view).offset(20)
//        }
//        
//        leftMoveButton.snp.makeConstraints { make in
//            make.centerY.equalTo(self.dateLabel.snp.centerY)
//            make.trailing.equalTo(self.rightMoveButton.snp.leading).offset(-5)
//        }
//        
//        rightMoveButton.snp.makeConstraints { make in
//            make.centerY.equalTo(self.dateLabel.snp.centerY)
//            make.trailing.equalTo(self.view).offset(-20)
//        }
//        
//        inComeStackView.snp.makeConstraints { make in
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(dateLabel.snp.bottom).offset(30)
//            make.leading.equalTo(self.view).offset(20)
//        }
//        
//        withdrawStackView.snp.makeConstraints { make in
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(inComeStackView.snp.bottom).offset(30)
//            make.leading.equalTo(self.view).offset(20)
//        }
//        
//        littleMoneyTextLabel.snp.makeConstraints { make in
//            make.top.equalTo(withdrawStackView.snp.bottom).offset(30)
//            make.leading.equalTo(self.view).offset(20)
//        }
        
//        graphView.snp.makeConstraints { make in
//            make.size.equalTo(250)
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(littleMoneyTextLabel.snp.bottom).offset(30)
//        }
//        
//        categoryView.snp.makeConstraints { make in
//            make.height.equalTo(30)
//            make.top.equalTo(graphView.snp.bottom).offset(30)
//            make.centerX.equalTo(self.view)
//            make.leading.equalTo(self.view).offset(30)
//        }
//        
//        // 수입/소비 테이블 뷰
//        inOutView.snp.makeConstraints { make in
//            make.top.equalTo(categoryView.snp.bottom).offset(50)
//            make.leading.equalTo(self.view).offset(30)
//            make.centerX.equalTo(self.view)
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
//        }
        
    }
}

extension StatisticViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return 1
            
        case 2:
            return 1    // 수정필요
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
            
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarChartTableViewCell", for: indexPath) as! BarChartTableViewCell
            
            return cell
        
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartTableViewCell", for: indexPath) as! PieChartTableViewCell
            
            return cell
        
        default:
            return UITableViewCell()
        }
    }
}

extension StatisticViewController: UITableViewDelegate {
    
}
