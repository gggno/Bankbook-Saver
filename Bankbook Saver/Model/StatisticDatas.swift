//
//  StatisticDatas.swift
//  Bankbook Saver
//
//  Created by 정근호 on 4/25/25.
//

import Foundation

struct StatisticData {
    let dateText: String
    let outComeMoneyText: String
    let inComeMoneyText: String
    let lastCompareText: String
    let barChartDatas: [BarChartInfo]
    let pieChartDatas: [PieChartInfo]
    let inOutDatas: [String: [InOutCellInfo]]
}
