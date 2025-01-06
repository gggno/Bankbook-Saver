//
//  PieChartTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit

class PieChartTableViewCell: UITableViewCell {

    lazy var pieChartView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubViews()
        setLayout()
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
        print("PieChartTableViewCell - addSubViews() called")
        
        self.contentView.addSubview(pieChartView)
    }
    
    func setLayout() {
        print("PieChartTableViewCell - setLayout() called")
        
        pieChartView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
    }

}
