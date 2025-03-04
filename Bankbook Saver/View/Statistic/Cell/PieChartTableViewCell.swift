//
//  PieChartTableViewCell.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/6/25.
//

import UIKit
import SwiftUI
import SnapKit

class PieChartTableViewCell: UITableViewCell {
    
    var pieChartDatas: [PieChartInfo] = [] {
        didSet {
            updatePieChart()
        }
    }
    
    private var hostingController: UIHostingController<PieChart>?
    
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
        self.contentView.addSubview(pieChartView)
    }
    
    func setLayout() {
        pieChartView.snp.makeConstraints { make in
            make.height.equalTo(250)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
    }
    
    private func updatePieChart() {
        hostingController?.view.removeFromSuperview()
        
        let newHostingController = UIHostingController(rootView: PieChart(pieChartDatas: pieChartDatas))
        hostingController = newHostingController
        guard let pieChart = hostingController?.view else {return}
        
        self.pieChartView.addSubview(pieChart)
        
        pieChart.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
