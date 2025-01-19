//
//  MypageReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import Foundation
import ReactorKit

class MypageReactor: Reactor {
    
    // in
    enum Action {
        
        
        
        case getCurrentVersionAction    // 현재 버전 가져오기
    }
    
    // 연산
    enum Mutation {
        
        
        
        case getCurrentVersionMutation(version: String) // 현재 버전 가져오기
    }
    
    // out
    struct State {
        var currentVersion: String = ""
        var myPageHeaders: [String] = ["일반", "알림", "저축 관리", "기타"]
        var myPageRow: [[MypageCellInfo]] = [[MypageCellInfo(title: "위시리스트",
                                                             rightImageName: "chevron.right"),
                                              MypageCellInfo(title: "다크/라이트모드 설정",
                                                             rightImageName:"chevron.right",
                                                             rightImageText: "시스템")],
                                             
                                             [MypageCellInfo(title: "알림 설정",
                                                             rightImageName: "chevron.right")],
                                             
                                             [MypageCellInfo(title: "계좌 관리",
                                                             rightImageName: "chevron.right")],
                                             
                                             [MypageCellInfo(title: "별점 선물하기",
                                                             rightText: "\u{2B50}\u{2B50}\u{2B50}\u{2B50}\u{2B50}"),
                                              MypageCellInfo(title: "앱 버전",
                                                             rightText: "v1.0.0")]
                                             ]
    }
    
    let initialState: State = State()
}

extension MypageReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .getCurrentVersionAction:  // 현재 버전 가져오기
            if let dictionary = Bundle.main.infoDictionary,
               let version = dictionary["CFBundleShortVersionString"] as? String {
                return Observable.just(.getCurrentVersionMutation(version: "v\(version)"))
            } else {
                return Observable.just(.getCurrentVersionMutation(version: ""))
            }
        }
    }
}

extension MypageReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .getCurrentVersionMutation(let version):
            newState.currentVersion = version
            newState.myPageRow[3][1].rightText = version
            return newState
        }
    }
}
