//
//  BarChart.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import SwiftUI
import Charts

struct BarChart: View {
    
    let barChartDatas: [BarChartInfo] = [
        .init(month: "7월", spendMoney: 50),
        .init(month: "8월", spendMoney: 30),
        .init(month: "9월", spendMoney: 80),
        .init(month: "10월", spendMoney: 75),
        .init(month: "11월", spendMoney: 42),
        .init(month: "12월", spendMoney: 68)
    ]
    
    var body: some View {
        Chart(barChartDatas) { barChartData in
            BarMark(x: .value("month", barChartData.month), y: .value("spendMoney", barChartData.spendMoney))
        }
    }
}

#Preview {
    BarChart()
}
