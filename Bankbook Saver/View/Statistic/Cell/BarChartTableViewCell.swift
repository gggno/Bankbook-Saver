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
        label.font = .systemFont(ofSize: 17, weight: .semibold)
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
        self.contentView.backgroundColor = .systemGroupedBackground
        
        barChartView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top).offset(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
        }
        
        previousSpendLabel.snp.makeConstraints { make in
            make.top.equalTo(self.barChartView.snp.top)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.leading.equalToSuperview()
        }
    }
    
    func updateBarChart() {
        hostingController?.view.removeFromSuperview()
        
        let newHostingController = UIHostingController(rootView: BarChart(barChartDatas: barChartDatas))
        hostingController = newHostingController
        guard let barChart = hostingController?.view else {return}
        barChart.backgroundColor = .secondarySystemGroupedBackground
        
        self.barChartView.addSubview(barChart)
        barChart.layer.cornerRadius = 20
        
        barChart.snp.makeConstraints { make in
            make.top.equalTo(previousSpendLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
