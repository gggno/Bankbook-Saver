//
//  Int + Comma.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/17/25.
//

import Foundation

extension Int {
    // 숫자에 콤마 넣기
    var withComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: self as NSNumber)!
    }
}
