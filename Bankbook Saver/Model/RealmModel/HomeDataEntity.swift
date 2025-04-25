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
    
    convenience init(homeData: HomeDataEntity, changedDate: Date) {
        self.init()
        
        self._id = homeData._id
        self.transactionType = homeData.transactionType
        self.money = homeData.money
        self.purposeText = homeData.purposeText
        self.purposeDate = changedDate
        self.repeatState = homeData.repeatState
        self.expenseKind = homeData.expenseKind
        self.selectedCategoryIndex = homeData.selectedCategoryIndex
        self.memoText = homeData.memoText
    }
}
