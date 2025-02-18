//
//  CategoryCollectionViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/13/25.
//

import UIKit
import SnapKit

class CategoryCollectionViewCell: UICollectionViewCell {
    lazy var emijiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
//        label.backgroundColor = .red
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
//        label.backgroundColor = .blue
        return label
    }()
    
    lazy var cagegoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubViews() {
        self.contentView.addSubview(cagegoryStackView)
        
        cagegoryStackView.addArrangedSubview(emijiLabel)
        cagegoryStackView.addArrangedSubview(nameLabel)
        
    }
    
    func setLayout() {
        cagegoryStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
