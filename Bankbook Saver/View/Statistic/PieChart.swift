//
//  PieChart.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import SwiftUI
import Charts

struct PieChart: View {
    
    @State var pieChartDatas: [PieChartInfo] = []
    
    var body: some View {
        Chart(pieChartDatas) { chartData in
            SectorMark(angle: .value("금액", chartData.amount))
                .foregroundStyle(by: .value("카테고리", chartData.category))
        }
        .padding(20)
    }
}

#Preview {
    PieChart()
}
