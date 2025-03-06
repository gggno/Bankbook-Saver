//
//  RealmManager.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/20/25.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    // 첫번째 실행 DB 생성
    func createIsFirstLaunch() {
        let realm = try! Realm()
        
        let isFirstLaunch = IsFirstLaunchEntity()
        isFirstLaunch.isFirstLaunch = true
        
        try! realm.write {
            realm.add(isFirstLaunch)
        }
    }
    
    // 화면모드 DB 생성
    func creatDisplayMode(displayMode: String) {
        let realm = try! Realm()
        
        let myPageDisplayMode = MyPageDisplayModeEntity()
        myPageDisplayMode.displayMode = displayMode
        
        try! realm.write {
            realm.add(myPageDisplayMode)
        }
    }
    
    // 화면모드 DB 데이터 업데이트
    func updateDisplayMode(displayMode: String) {
        let realm = try! Realm()
        
        let myPageDisplayMode = realm.objects(MyPageDisplayModeEntity.self).first!
        
        try! realm.write {
            myPageDisplayMode.displayMode = displayMode
        }
    }
}
