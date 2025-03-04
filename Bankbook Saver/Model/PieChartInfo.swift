//
//  PieChartInfo.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import Foundation

struct PieChartInfo: Identifiable, Equatable {
    let id: UUID = UUID()
    
    let category: String
    let amount: Int
}
