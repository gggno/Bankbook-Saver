//
//  HomeCalenderTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class HomeCalenderTableViewCell: UITableViewCell {
    
    // 선택한 달의 날 데이터(ex 1...31)
    var dayValue: [String] = []
    // 지출/수입 금액 데이터
    var inComeMoneys = BehaviorRelay<[Int]>(value: [])
    var outComeMoneys = BehaviorRelay<[Int]>(value: [])
    
    let lastMonthButtonTapped = PublishSubject<Void>()
    let nextMonthButtonTapped = PublishSubject<Void>()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var lastMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowtriangle.left.fill"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    lazy var monthLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    lazy var monthStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.backgroundColor = .systemGroupedBackground
        
        return stackView
    }()
    
    lazy var weekStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .systemGroupedBackground
        
        return stackView
    }()
    
    lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(HomeCalenderCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCalenderCollectionViewCell")
        
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubViews()
        setLayout()
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        lastMonthButton.rx.tap
            .bind(to: lastMonthButtonTapped)
            .disposed(by: disposeBag)
        
        nextMonthButton.rx.tap
            .bind(to: nextMonthButtonTapped)
            .disposed(by: disposeBag)
        
        // collectionView 리로드
        Observable.combineLatest(inComeMoneys, outComeMoneys)
            .distinctUntilChanged { lhs, rhs in
                    return lhs == rhs
                }
            .subscribe(onNext: { [weak self] _, _ in
                self?.calendarCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func addSubViews() {
        self.contentView.backgroundColor = .systemGroupedBackground
        
        self.contentView.addSubview(monthStackView)
        monthStackView.addArrangedSubview(lastMonthButton)
        monthStackView.addArrangedSubview(monthLabel)
        monthStackView.addArrangedSubview(nextMonthButton)
        
        self.contentView.addSubview(weekStackView)
        
        for day in ["일", "월", "화", "수", "목", "금", "토"] {
            let label = UILabel()
//            label.backgroundColor = .brown
            label.text = day
            label.textAlignment = .center
            
            weekStackView.addArrangedSubview(label)
        }
        
        self.contentView.addSubview(calendarCollectionView)
    }
    
    func setLayout() {
        calendarCollectionView.backgroundColor = .systemGroupedBackground
        
        monthStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        weekStackView.snp.makeConstraints { make in
            make.top.equalTo(monthStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalTo(calendarCollectionView.snp.top)
        }
        
        calendarCollectionView.snp.makeConstraints { make in
            // 60: minimumInteritemSpacing의 개수(고정)
            // 20: leading(10), trailing(20)의 EdgeInset(고정)
            // 7: 요일개수(고정)
            // 5: 줄 개수(유동적)
            // 40: minimumLineSpacing의 개수(유동적)
            // 20: top(10), bottom(10)의 EdgeInset(고정)
            make.height.equalTo((UIScreen.main.bounds.width - 60 - 20) / 7 * 5 + 10 * 40 + 20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // 콜렉션 뷰 높이 업데이트
    func updateCollectionViewHeight(lineCnt: Int) {
        calendarCollectionView.snp.updateConstraints { make in
            make.height.equalTo((UIScreen.main.bounds.width - 60 - 20) / 7 * CGFloat(lineCnt) + 10 * CGFloat(lineCnt-1) + 20)
        }
    }
    
}

extension HomeCalenderTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCalenderCollectionViewCell", for: indexPath) as! HomeCalenderCollectionViewCell
        cell.dateLabel.text = dayValue[indexPath.row]
        
        cell.inLabel.text = String(inComeMoneys.value[indexPath.row]) != "0" ? 
        inComeMoneys.value[indexPath.row].withComma : ""
        
        cell.outLabel.text = String(outComeMoneys.value[indexPath.row]) != "0" ?
        outComeMoneys.value[indexPath.row].withComma : ""
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension HomeCalenderTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 60: minimumInteritemSpacing의 개수(고정)
        // 20: leading(10), trailing(20)의 EdgeInset(고정)
        let width = (UIScreen.main.bounds.width - 60 - 20) / 7
        
        return CGSize(width: width, height: width)
    }
}

extension HomeCalenderTableViewCell: UICollectionViewDelegate {
    
}
