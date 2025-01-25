//
//  HomeSectionType.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/20/25.
//

import Foundation

enum HomeSectionType: Int, CaseIterable {
    case homeCalendar = 0
    case homeInOutList = 1
    
    init(section: Int) {
        switch section {
        case 0:
            self = .homeCalendar
            
        default:
            self = .homeInOutList
        }
    }
    
}
