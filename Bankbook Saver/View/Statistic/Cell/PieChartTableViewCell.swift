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

    lazy var pieChart: UIView = {
        let hostingController = UIHostingController(rootView: PieChart())
        return hostingController.view
    }()
    
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
        pieChartView.addSubview(pieChart)
        
        self.contentView.addSubview(pieChartView)
    }
    
    func setLayout() {
        pieChart.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pieChartView.snp.makeConstraints { make in
            make.height.equalTo(250)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
    }

}
