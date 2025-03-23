//
//  InputFieldView.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/10/25.
//

import UIKit
import SnapKit

class InputFieldView: UIView, UITextFieldDelegate {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        return toolbar
    }()
    
    lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    init(title: String, placeholder: String, keyboardType: UIKeyboardType = .default, unitText: String? = nil) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        unitLabel.text = unitText
        unitLabel.isHidden = unitText == nil
        
        textField.delegate = self
        
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
            make.height.equalTo(45)
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
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // 입력값 변경 시 콤마 추가
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("textFieldDidChange")
        guard let text = textField.text?.replacingOccurrences(of: ",", with: ""), let number = Int(text) else { return }
        
        textField.text = number.withComma
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
}
