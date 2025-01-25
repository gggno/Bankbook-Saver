//
//  StatisticSectionType.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/20/25.
//

import Foundation

enum StatisticSectionType: Int, CaseIterable {
    case stats = 0
    case barChart = 1
    case pieChart = 2
    case inputList = 3
    
    init(section: Int) {
        switch section {
        case 0:
            self = .stats
        case 1:
            self = .barChart
        case 2:
            self = .pieChart
        default:
            self = .inputList
        }
    }
}
