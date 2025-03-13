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
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.register(HomeCalenderTableViewCell.self, forCellReuseIdentifier: "HomeCalenderTableViewCell")
        //        tableView.register(SelectedInOutTableViewCell.self, forCellReuseIdentifier: "SelectedInOutTableViewCell")
        tableView.register(InOutListTableViewCell.self, forCellReuseIdentifier: "InOutListTableViewCell")
        return tableView
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        // UI 설정
        addSubViews()
        setLayout()
        
        self.reactor = HomeReactor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("HomeViewController - viewWillAppear() called")

        // 처음에 날짜 가져오기(초기값 0)
        self.reactor?.action.onNext(.fetchDataAction(count: 0))
        homeTableView.reloadData()
        // calendarCollectionView reload 해야 됨
    }
    
    @objc func searchHomeData() {
        print("HomeViewController - searchHomeData() called")
        
        let searchHomeDataVC = SearchHomeDataViewController()
        self.navigationController?.pushViewController(searchHomeDataVC, animated: true)
    }
}

// MARK: - UI
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchHomeData))
        
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
//        // 처음에 날짜 가져오기(초기값 0)
//        reactor.action.onNext(.fetchDataAction(count: 0))
        
        // 이전 달 또는 다음 달 날짜 가져오기
        homeTableView.rx.willDisplayCell
            .compactMap { ($0.cell as? HomeCalenderTableViewCell) }
            .distinctUntilChanged()
            .subscribe { cell in
                cell.lastMonthButtonTapped
                    .subscribe(onNext: {
                        print("이전 달 버튼 탭 감지")
                        reactor.action.onNext(.fetchDataAction(count: -1))
                        cell.dayValue = reactor.currentState.selectedDays
                        cell.calendarCollectionView.reloadData()
                        self.homeTableView.reloadData()
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.nextMonthButtonTapped
                    .subscribe(onNext: {
                        print("다음 달 버튼 탭 감지")
                        reactor.action.onNext(.fetchDataAction(count: 1))
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
                
                addVC.expenseView.isHidden = false
                addVC.inComeView.isHidden = true
                
                self.navigationController?.pushViewController(addVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (reactor?.currentState.inOutData.keys.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
            
        case 1...:
            if let headers = reactor?.currentState.inOutData.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                return headers[section - 1]
            }
            
            return nil
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1...:
            if let headers = reactor?.currentState.inOutData.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                let key = headers[section - 1]
                return reactor?.currentState.inOutData[key]?.count ?? 0
            }
            
            return 0
                
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = HomeSectionType(section: indexPath.section)
        
        switch sectionType {
        case .homeCalendar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCalenderTableViewCell", for: indexPath) as! HomeCalenderTableViewCell
            
            cell.selectionStyle = .none
            
            cell.monthLabel.text = self.reactor?.currentState.selectedMonth
            
            let days = self.reactor?.currentState.selectedDays ?? []
            cell.dayValue = days
            
            let inComeMoneys = self.reactor?.currentState.inComeMoneys ?? []
            cell.inComeMoneys.accept(inComeMoneys)
            
            let outComeMoneys = self.reactor?.currentState.outComeMoneys ?? []
            cell.outComeMoneys.accept(outComeMoneys)
            
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
            
            cell.selectionStyle = .none
            
            if let headers = reactor?.currentState.inOutData.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                let key = headers[indexPath.section - 1]
                if let inOutCell = reactor?.currentState.inOutData[key] {
                    cell.emojiLabel.text = inOutCell[indexPath.row].emoji
                    cell.moneyLabel.text = inOutCell[indexPath.row].money
                    cell.detailUseLabel.text = inOutCell[indexPath.row].detailUse
                }
            }
             
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionType = HomeSectionType(section: indexPath.section)
        
        switch sectionType {
        case .homeCalendar:
            break
            
        case .homeInOutList:
            if let headers = reactor?.currentState.inOutData.keys.sorted(by: { lhs, rhs in
                let leftDay = Int(lhs.components(separatedBy: "일").first ?? "0") ?? 0
                let rightDay = Int(rhs.components(separatedBy: "일").first ?? "0") ?? 0
                return leftDay < rightDay
            }) {
                let key = headers[indexPath.section - 1]
                if let inOutCell = reactor?.currentState.inOutData[key],
                   let thisMonthDatas = reactor?.currentState.thisMonthDatas,
                   let selectedIndex = thisMonthDatas.firstIndex(where: { $0._id.stringValue == inOutCell[indexPath.row].id }) {
                    
                    let addVC = AddTransactionViewController()
                    addVC.transactionId = thisMonthDatas[selectedIndex]._id.stringValue
                    
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.isHidden = false
                        addVC.inComeView.isHidden = true
                    } else {
                        addVC.expenseView.isHidden = true
                        addVC.inComeView.isHidden = false
                    }
                    
                    // 지출/수입 세그먼트 컨트롤
                    addVC.segmentControl.selectedSegmentIndex = thisMonthDatas[selectedIndex].transactionType == "지출" ? 0 : 1
                    // 머니 텍스트
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.moneyInputFieldView.textField.text = thisMonthDatas[selectedIndex].money
                    } else {
                        addVC.inComeView.moneyInputFieldView.textField.text = thisMonthDatas[selectedIndex].money
                    }
                    
                    // 지출처/수입처
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.expensePurposeInputFieldView.textField.text = thisMonthDatas[selectedIndex].purposeText
                    } else {
                        addVC.inComeView.incomePurposeInputFieldView.textField.text = thisMonthDatas[selectedIndex].purposeText
                    }
                    
                    // 일시
                    addVC.expenseView.expenseSelectedDate.onNext(thisMonthDatas[selectedIndex].purposeDate)
                    addVC.inComeView.incomeSelectedDate.onNext(thisMonthDatas[selectedIndex].purposeDate)
                    
                    // 매월 반복
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.repeatState.isOn = thisMonthDatas[selectedIndex].repeatState
                    } else {
                        addVC.inComeView.repeatState.isOn = thisMonthDatas[selectedIndex].repeatState
                    }
                    
                    // 지불 수단(지출인 경우만)
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.typeSegmentControl.selectedSegmentIndex = thisMonthDatas[selectedIndex].expenseKind
                    }
                    
                    // 카테고리
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.selectedIndexPath = [0, thisMonthDatas[selectedIndex].selectedCategoryIndex]
                        addVC.expenseView.selectedCategoryIndex.onNext(thisMonthDatas[selectedIndex].selectedCategoryIndex)
                    } else {
                        addVC.inComeView.selectedIndexPath = [0, thisMonthDatas[selectedIndex].selectedCategoryIndex]
                        addVC.inComeView.selectedCategoryIndex.onNext(thisMonthDatas[selectedIndex].selectedCategoryIndex)
                    }
                    
                    // 메모
                    if thisMonthDatas[selectedIndex].transactionType == "지출" {
                        addVC.expenseView.memoTextField.text = thisMonthDatas[selectedIndex].memoText
                    } else {
                        addVC.inComeView.memoTextField.text = thisMonthDatas[selectedIndex].memoText
                    }
                    
                    self.navigationController?.pushViewController(addVC, animated: true)
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
}
