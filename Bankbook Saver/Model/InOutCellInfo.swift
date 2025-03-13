//
//  InOutCellInfo.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/7/25.
//

import Foundation

struct InOutCellInfo: Equatable {
    let id: String
    let transactionType: String
    let emoji: String
    let money: String
    let detailUse: String
}
