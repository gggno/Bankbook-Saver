//
//  String + Comma.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/17/25.
//

import Foundation

extension String {
    // 숫자에 콤마 빼기
    var withOutComma: Int {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.number(from: self) as! Int 
    }
}
