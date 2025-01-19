//
//  HomeCalenderTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/8/25.
//

import UIKit
import SnapKit

class HomeCalenderTableViewCell: UITableViewCell {
    
    // 임시 위치(enum, 선언 위치 변경 해야 함)
    let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    // 임시 데이터
    var dayValue: [String] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31].map{String($0)}
    
    lazy var weekStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
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
        print("HomeCalenderTableViewCell - addSubViews() called")
        self.contentView.addSubview(weekStackView)
        
        for day in days {
            let label = UILabel()
            label.backgroundColor = .brown
            label.text = day
            label.textAlignment = .center
            
            weekStackView.addArrangedSubview(label)
        }
        
        self.contentView.addSubview(calendarCollectionView)
    }
    
    func setLayout() {
        print("HomeCalenderTableViewCell - setLayout() called")
        calendarCollectionView.backgroundColor = .green

        weekStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
            make.height.equalTo((UIScreen.main.bounds.width - 60 - 20) / 7 * 5 + 40 + 20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
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
