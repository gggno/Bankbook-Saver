//
//  CategoryType.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/13/25.
//

import Foundation

import UIKit

enum CategoryType: Int, CaseIterable {
    case food = 0
    case transport = 1
    case utility = 2
    case medical = 3
    case subscription = 4
    case communication = 5
    case fitness = 6
    case essentials = 7
    case cafe = 8
    case shopping = 9
    case investment = 10
    case gift = 11
    case education = 12
    case beauty = 13
    case insurance = 14
    case other = 15

    var emoji: String {
        switch self {
        case .food: return "🍚"             // 식비
        case .transport: return "🚗"        // 교통/차량
        case .utility: return "📜"          // 공과금
        case .medical: return "💊"          // 의료비
        case .subscription: return "🍿"     // 구독비
        case .communication: return "📱"    // 통신비
        case .fitness: return "💪"          // 운동
        case .essentials: return "🛒"       // 생필품
        case .cafe: return "☕"             // 카페
        case .shopping: return "🛍️"         // 쇼핑
        case .investment: return "💰"       // 저축/투자
        case .gift: return "🎁"             // 선물
        case .education: return "📖"        // 교육
        case .beauty: return "🪞"           // 미용
        case .insurance: return "☂️"        // 보험
        case .other: return "🎸"            // 기타
        }
    }

    var title: String {
        switch self {
        case .food: return "식비"
        case .transport: return "교통/차량"
        case .utility: return "공과금"
        case .medical: return "의료비"
        case .subscription: return "구독비"
        case .communication: return "통신비"
        case .fitness: return "운동"
        case .essentials: return "생필품"
        case .cafe: return "카페"
        case .shopping: return "쇼핑"
        case .investment: return "저축/투자"
        case .gift: return "선물"
        case .education: return "교육"
        case .beauty: return "미용"
        case .insurance: return "보험"
        case .other: return "기타"
        }
    }
}
