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
        .padding(20)
        .chartXAxis {   // 백그라운드 격자 선 제거
            AxisMarks() { _ in
                AxisValueLabel()
                AxisTick().foregroundStyle(.clear)
                AxisGridLine().foregroundStyle(.clear)
            }
        }
        .chartYAxis {   // 백그라운드 격자 선 제거
            AxisMarks() { _ in
                AxisValueLabel()
                AxisTick().foregroundStyle(.clear)
                AxisGridLine().foregroundStyle(.clear)
            }
        }
    }
}

#Preview {
    BarChart()
}
