//
//  HomeDataEntity.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/13/25.
//

import Foundation
import RealmSwift

class HomeDataEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var transactionType: String
    @Persisted var money: String
    @Persisted var purposeText: String
    @Persisted var purposeDate: Date
    @Persisted var repeatState: Bool
    @Persisted var expenseKind: Int
    @Persisted var selectedCategoryIndex: Int
    @Persisted var memoText: String
    
    convenience init(_id: ObjectId, transactionType: String, money: String, purposeText: String, purposeDate: Date, repeatState: Bool, expenseKind: Int, selectedCategoryIndex: Int, memoText: String) {
        self.init()
        
        self._id = _id
        self.transactionType = transactionType
        self.money = money
        self.purposeText = purposeText
        self.purposeDate = purposeDate
        self.repeatState = repeatState
        self.expenseKind = expenseKind
        self.selectedCategoryIndex = selectedCategoryIndex
        self.memoText = memoText
    }
}
