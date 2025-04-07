//
//  MypageReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import Foundation
import ReactorKit
import RealmSwift
import UIKit

class MypageReactor: Reactor {
    
    // in
    enum Action {
        case fetchMypageDatasAction             // 디비에서 데이터 가져오기
        
        case updateDisplayModeAction(String)    // 화면 모드 변경하기
        
        case getCurrentVersionAction            // 현재 버전 가져오기
        
        case appStoreReviewAction               // 앱스토어 리뷰 작성으로 이동
    }
    
    // 연산
    enum Mutation {
        // 내부 디비에 저장된 데이터 불러오기
        case fetchMypageDatasMutation(wishItems: [MypageWishDataEntity],
                                      myPageDisplayMode: MyPageDisplayModeEntity,
                                      notiDatas: [MypageNotiEntity],
                                      accountDatas: [MypageAccountEntity])
        
        case updateDisplayModeMutation(String)
        
        case getCurrentVersionMutation(version: String) // 현재 버전 가져오기
    }
    
    // out
    struct State {
        var myPageHeaders: [String] = ["일반", "알림", "기타"]
        var myPageRow: [[MypageCellInfo]] = [[MypageCellInfo(title: "다크/라이트모드 설정",
                                                            rightImageName:"chevron.right",
                                                            rightImageText: "기본값")
                                              ],
                                             
                                             [MypageCellInfo(title: "알림 설정",
                                                             rightImageName: "chevron.right")],
                                             
                                             [MypageCellInfo(title: "별점 선물하기",
                                                             rightText: "\u{2B50}\u{2B50}\u{2B50}\u{2B50}\u{2B50}"),
                                              MypageCellInfo(title: "앱 버전",
                                                             rightText: "v1.0.0")]
                                             ]
        var wishItems: [MypageWishDataEntity] = []
        
        var myPageDisplayMode: MyPageDisplayModeEntity = MyPageDisplayModeEntity()
        var displayIntType = DisplayRowIntType.system.rawValue
        var myDisplayMode: MyPageDisplayModeEntity = MyPageDisplayModeEntity()
        
        var notiDatas: [MypageNotiEntity] = []
        var accountDatas: [MypageAccountEntity] = []
        
        var currentVersion: String = ""
    }
    
    let initialState: State = State()
    
    let realm = try! Realm()
}

extension MypageReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMypageDatasAction:                       // 디비에서 데이터 가져오기
            let wishItemsResults = realm.objects(MypageWishDataEntity.self)
            let wishItems: [MypageWishDataEntity] = Array(wishItemsResults)
            
            let myPageDisplayMode = realm.objects(MyPageDisplayModeEntity.self).first ?? MyPageDisplayModeEntity()
            
            let notiDatasResult = Array(realm.objects(MypageNotiEntity.self))
            let notiDatas = notiDatasResult
            
            let accountDatasResult = Array(realm.objects(MypageAccountEntity.self))
            let accountDatas = accountDatasResult
            
            return Observable.just(.fetchMypageDatasMutation(wishItems: wishItems,
                                                             myPageDisplayMode: myPageDisplayMode,
                                                             notiDatas: notiDatas,
                                                             accountDatas: accountDatas))
            
            
        case .updateDisplayModeAction(let displayMode):     // 화면모드 업데이트
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                switch displayMode {
                case DisplayType.dark.rawValue:
                    if realm.objects(MyPageDisplayModeEntity.self).first != nil {
                        RealmManager.shared.updateDisplayMode(displayMode: DisplayType.dark.rawValue)
                    } else {
                        RealmManager.shared.creatDisplayMode(displayMode: DisplayType.dark.rawValue)
                    }
                    window.overrideUserInterfaceStyle = .dark
                    
                    return Observable.just(.updateDisplayModeMutation("다크"))
               
                case DisplayType.light.rawValue:
                    if realm.objects(MyPageDisplayModeEntity.self).first != nil {
                        RealmManager.shared.updateDisplayMode(displayMode: DisplayType.light.rawValue)
                    } else {
                        RealmManager.shared.creatDisplayMode(displayMode: DisplayType.light.rawValue)
                    }
                    window.overrideUserInterfaceStyle = .light
                   
                    return Observable.just(.updateDisplayModeMutation("라이트"))
                
                default:
                    if realm.objects(MyPageDisplayModeEntity.self).first != nil {
                        RealmManager.shared.updateDisplayMode(displayMode: DisplayType.system.rawValue)
                    } else {
                        RealmManager.shared.creatDisplayMode(displayMode: DisplayType.system.rawValue)
                    }
                    window.overrideUserInterfaceStyle = .unspecified
                    
                    return Observable.just(.updateDisplayModeMutation("시스템"))
                }
            } else {
                return Observable.just(.updateDisplayModeMutation("시스템"))
            }
            
            
        case .getCurrentVersionAction:                      // 현재 버전 가져오기
            if let dictionary = Bundle.main.infoDictionary,
               let version = dictionary["CFBundleShortVersionString"] as? String {
                return Observable.just(.getCurrentVersionMutation(version: "v\(version)"))
            } else {
                return Observable.just(.getCurrentVersionMutation(version: ""))
            }
            
        case .appStoreReviewAction:                         // 앱스토어 리뷰 작성으로 이동
            if let writeReviewURL = URL(string: "https://apps.apple.com/kr/app/%ED%85%85%EC%9E%A5-%EC%84%B8%EC%9D%B4%EB%B2%84/id6743690834?action=write-review") {
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            }
            return .empty()
        }
    }
}

extension MypageReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchMypageDatasMutation(let wishItems,
                                       let myPageDisplayMode,
                                       let notiDatas,
                                       let accountDatas):
            
            // 다크/라이트모드 텍스트로 보여주기
            switch myPageDisplayMode.displayMode {
            case DisplayType.dark.rawValue:
                newState.displayIntType = DisplayRowIntType.dark.rawValue
                newState.myPageRow[0][0].rightImageText = "다크"
                
            case DisplayType.light.rawValue:
                newState.displayIntType = DisplayRowIntType.light.rawValue
                newState.myPageRow[0][0].rightImageText = "라이트"
                
            case DisplayType.system.rawValue:
                newState.displayIntType = DisplayRowIntType.system.rawValue
                newState.myPageRow[0][0].rightImageText = "시스템"
                
            default:
                newState.displayIntType = DisplayRowIntType.system.rawValue
                newState.myPageRow[0][0].rightImageText = "시스템"
            }
            
            return newState
            
            
        case .updateDisplayModeMutation(let displayMode):
            newState.myDisplayMode.displayMode = displayMode
            switch displayMode {
            case "다크":
                newState.displayIntType = DisplayRowIntType.dark.rawValue
                newState.myPageRow[0][0].rightImageText = "다크"
            case "라이트":
                newState.displayIntType = DisplayRowIntType.light.rawValue
                newState.myPageRow[0][0].rightImageText = "라이트"
            case "시스템":
                newState.displayIntType = DisplayRowIntType.system.rawValue
                newState.myPageRow[0][0].rightImageText = "시스템"
            default:
                break
            }
            
            return newState
            
        case .getCurrentVersionMutation(let version):
            newState.currentVersion = version
            newState.myPageRow[2][1].rightText = version
            return newState
        
        }
    }
}
