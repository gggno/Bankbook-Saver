//
//  PieChart.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import SwiftUI
import Charts

struct PieChart: View {
    
    let pieChartDatas: [PieChartInfo] = [
        .init(category: "교통비", amount: 123000),
        .init(category: "식비", amount: 355000),
        .init(category: "병원비", amount: 78000),
        .init(category: "통신비", amount: 50000),
        .init(category: "쇼핑", amount: 243000)
    ]
    
    var body: some View {
        Chart(pieChartDatas) { chartData in
            SectorMark(angle: .value("금액", chartData.amount))
                .foregroundStyle(by: .value("카테고리", chartData.category))
        }
    }
}

#Preview {
    PieChart()
}
