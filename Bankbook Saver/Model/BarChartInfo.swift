//
//  BarChartInfo.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import Foundation

struct BarChartInfo: Identifiable, Equatable {
    var id: UUID = UUID()
    
    let month: String
    let spendMoney: Int
}
