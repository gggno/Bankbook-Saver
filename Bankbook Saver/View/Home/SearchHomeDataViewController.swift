//
//  SearchHomeDataViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/12/25.
//

import UIKit
import SnapKit
import ReactorKit

class SearchHomeDataViewController: UIViewController {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    lazy var searchHomeDataTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(InOutListTableViewCell.self, forCellReuseIdentifier: "InOutListTableViewCell")
        return tableView
    }()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        setLayout()
        
        searchHomeDataTableView.delegate = self
        searchHomeDataTableView.dataSource = self
        
        self.reactor = SearchHomeDataReactor()
    }
}

// MARK: - UI
extension SearchHomeDataViewController {
    func addSubViews() {
        print("SearchHomeDataViewController - addSubViews() called")
        
        self.view.addSubview(searchBar)
        self.view.addSubview(searchHomeDataTableView)
    }
    
    // 레이아웃 설정
    func setLayout() {
        print("SearchHomeDataViewController - setLayout() called")
        
        self.view.backgroundColor = .systemGroupedBackground
        
        searchBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(10)
        }
        
        searchHomeDataTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension SearchHomeDataViewController: View {
    func bind(reactor: SearchHomeDataReactor) {
        
        // 검색어 변경 감지
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateSearchTextAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색어 변경 시 출력
        reactor.state.map { $0.searchText }
            .distinctUntilChanged()
            .subscribe(onNext: { searchText in
                print("검색어 변경됨: \(searchText)")
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.inOutDatas }
            .distinctUntilChanged()
            .subscribe(onNext: { datas in
                print("검색된 데이터: \(datas)")
                self.searchHomeDataTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
}

extension SearchHomeDataViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return reactor?.currentState.inOutDatas.keys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
            let lhsDateStr = String(lhs)
            let rhsDateStr = String(rhs)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            if let lhsDate = dateFormatter.date(from: lhsDateStr),
                let rhsDate = dateFormatter.date(from: rhsDateStr) {
                return lhsDate < rhsDate
            }
            
            return false
            
        }) {
            return headers[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
            let lhsDateStr = String(lhs)
            let rhsDateStr = String(rhs)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            if let lhsDate = dateFormatter.date(from: lhsDateStr),
                let rhsDate = dateFormatter.date(from: rhsDateStr) {
                return lhsDate < rhsDate
            }
            
            return false
            
        }) {
            let key = headers[section]
            return reactor?.currentState.inOutDatas[key]?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InOutListTableViewCell", for: indexPath) as! InOutListTableViewCell
        
        cell.selectionStyle = .none
        
        if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
            let lhsDateStr = String(lhs)
            let rhsDateStr = String(rhs)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            if let lhsDate = dateFormatter.date(from: lhsDateStr),
                let rhsDate = dateFormatter.date(from: rhsDateStr) {
                return lhsDate < rhsDate
            }
            
            return false
            
        }) {
            let key = headers[indexPath.section]
            
            if let inOutCell = reactor?.currentState.inOutDatas[key] {
                cell.emojiLabel.text = inOutCell[indexPath.row].emoji
                cell.moneyLabel.text = inOutCell[indexPath.row].money
                cell.detailUseLabel.text = inOutCell[indexPath.row].detailUse
            }
        }
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let headers = reactor?.currentState.inOutDatas.keys.sorted(by: { lhs, rhs in
            let lhsDateStr = String(lhs)
            let rhsDateStr = String(rhs)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            if let lhsDate = dateFormatter.date(from: lhsDateStr),
                let rhsDate = dateFormatter.date(from: rhsDateStr) {
                return lhsDate < rhsDate
            }
            
            return false
            
        }) {
            let key = headers[indexPath.section]
            if let inOutCell = reactor?.currentState.inOutDatas[key],
               let searchedDatas = reactor?.currentState.searchedHomeDatas,
               let selectedIndex = searchedDatas.firstIndex(where: { $0._id.stringValue == inOutCell[indexPath.row].id }) {
                
                let addVC = AddTransactionViewController()
                addVC.transactionId = searchedDatas[selectedIndex]._id.stringValue
                
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.isHidden = false
                    addVC.inComeView.isHidden = true
                } else {
                    addVC.expenseView.isHidden = true
                    addVC.inComeView.isHidden = false
                }
                
                // 지출/수입 세그먼트 컨트롤
                addVC.segmentControl.selectedSegmentIndex = searchedDatas[selectedIndex].transactionType == "지출" ? 0 : 1
                // 머니 텍스트
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.moneyInputFieldView.textField.text = searchedDatas[selectedIndex].money
                } else {
                    addVC.inComeView.moneyInputFieldView.textField.text = searchedDatas[selectedIndex].money
                }
                
                // 지출처/수입처
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.expensePurposeInputFieldView.textField.text = searchedDatas[selectedIndex].purposeText
                } else {
                    addVC.inComeView.incomePurposeInputFieldView.textField.text = searchedDatas[selectedIndex].purposeText
                }
                
                // 일시
                addVC.expenseView.expenseSelectedDate.onNext(searchedDatas[selectedIndex].purposeDate)
                addVC.inComeView.incomeSelectedDate.onNext(searchedDatas[selectedIndex].purposeDate)
                
                // 매월 반복
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.repeatState.isOn = searchedDatas[selectedIndex].repeatState
                } else {
                    addVC.inComeView.repeatState.isOn = searchedDatas[selectedIndex].repeatState
                }
                
                // 지불 수단(지출인 경우만)
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.typeSegmentControl.selectedSegmentIndex = searchedDatas[selectedIndex].expenseKind
                }
                
                // 카테고리
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.selectedIndexPath = [0, searchedDatas[selectedIndex].selectedCategoryIndex]
                    addVC.expenseView.selectedCategoryIndex.onNext(searchedDatas[selectedIndex].selectedCategoryIndex)
                } else {
                    addVC.inComeView.selectedIndexPath = [0, searchedDatas[selectedIndex].selectedCategoryIndex]
                    addVC.inComeView.selectedCategoryIndex.onNext(searchedDatas[selectedIndex].selectedCategoryIndex)
                }
                
                // 메모
                if searchedDatas[selectedIndex].transactionType == "지출" {
                    addVC.expenseView.memoTextField.text = searchedDatas[selectedIndex].memoText
                } else {
                    addVC.inComeView.memoTextField.text = searchedDatas[selectedIndex].memoText
                }
                
                self.navigationController?.pushViewController(addVC, animated: true)
            }
        }
    }
}

extension SearchHomeDataViewController: UITableViewDelegate {
    
}

