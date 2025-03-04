//
//  BarChartTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit
import SwiftUI
import SnapKit
import RxSwift
import RxRelay

class BarChartTableViewCell: UITableViewCell {
    
    var barChartDatas: [BarChartInfo] = [] {
        didSet {
            updateBarChart()
        }
    }
    
    private var hostingController: UIHostingController<BarChart>?
    
    lazy var previousSpendLabel: UILabel = {
        let label = UILabel()
        label.text = "11월에는 19만원 더 썼어요"
        return label
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
        barChartView.addSubview(previousSpendLabel)
        
        self.contentView.addSubview(barChartView)
    }
    
    func setLayout() {
        previousSpendLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(8)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.leading.equalToSuperview()
        }
        
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(previousSpendLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(150)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
    }
    
    func updateBarChart() {
        hostingController?.view.removeFromSuperview()
        
        let newHostingController = UIHostingController(rootView: BarChart(barChartDatas: barChartDatas))
        hostingController = newHostingController
        guard let barChart = hostingController?.view else {return}
        
        self.barChartView.addSubview(barChart)
        
        barChart.snp.makeConstraints { make in
            make.top.equalTo(previousSpendLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
