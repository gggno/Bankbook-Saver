//
//  BarChartTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit
import SwiftUI
import SnapKit

class BarChartTableViewCell: UITableViewCell {
    
    lazy var previousSpendLabel: UILabel = {
        let label = UILabel()
        label.text = "11월에는 19만원 더 썼어요"
        return label
    }()
    
    lazy var barChart: UIView = {
        let hostingController = UIHostingController(rootView: BarChart())
        return hostingController.view
    }()
    
    
    lazy var barChartView: UIView = {
        let view = UIView()
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
        print("BarChartTableViewCell - addSubViews() called")
        
        barChartView.addSubview(previousSpendLabel)
        
        barChartView.addSubview(barChart)
        
        self.contentView.addSubview(barChartView)
    }
    
    func setLayout() {
        print("BarChartTableViewCell - setLayout() called")
        
        previousSpendLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(8)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.leading.equalToSuperview()
        }
        
        barChart.snp.makeConstraints { make in
            make.top.equalTo(previousSpendLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        barChartView.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
    }
    
}
