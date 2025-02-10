//
//  InputFieldView.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/10/25.
//

import UIKit
import SnapKit

class InputFieldView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .brown
        return textField
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.backgroundColor = .red
        return label
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    init(title: String, placeholder: String, keyboardType: UIKeyboardType = .default, unitText: String? = nil) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        unitLabel.text = unitText
        unitLabel.isHidden = unitText == nil
        
        addSubViews()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubViews() {
        self.addSubview(titleLabel)
        self.addSubview(textField)
        self.addSubview(unitLabel)
        self.addSubview(underlineView)
    }
    
    func setLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            
        }
        
        unitLabel.snp.makeConstraints { make in
            make.size.equalTo(textField.snp.height)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(textField.snp.centerY)
            make.leading.equalTo(textField.snp.trailing)
        }
        
        underlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(textField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
