//
//  MypageDataEntity.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/21/25.
//

import Foundation
import RealmSwift

// 위시리스트
class MypageWishDataEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var wishItemName: String
    
    convenience init(wishItemName: String) {
        self.init()
        self.wishItemName = wishItemName
    }
}

// 화면 모드
class MyPageDisplayModeEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var displayMode: String
    
    convenience init(displayMode: String) {
        self.init()
        self.displayMode = displayMode
    }
}

// 알림
class MypageNotiEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var notiState: List<Bool> = List<Bool>()
    
    convenience init(notiState: List<Bool>) {
        self.init()
        self.notiState = notiState
    }
}

// 계좌
class MypageAccountEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var account: List<String> = List<String>()
    
    convenience init(accunt: List<String>) {
        self.init()
        self.account = accunt
    }
}
