//
//  BarChart.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import SwiftUI
import Charts

struct BarChart: View {
    
    @State var barChartDatas: [BarChartInfo] = []
    
    var body: some View {
        Chart(barChartDatas) { barChartData in
            BarMark(x: .value("month", barChartData.month),
                    y: .value("spendMoney", barChartData.spendMoney)
            )
        }
    }
}

#Preview {
    BarChart()
}
