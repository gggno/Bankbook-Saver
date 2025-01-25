//
//  DarkLightReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 1/23/25.
//

import Foundation
import ReactorKit
import UIKit

class DarkLightReactor: Reactor {
    
    enum Action {
        case updateMyPageDisplayModeAction(String)
    }
    
    enum Mutation {
        case updateMyPageDisplayModeMutation(String)
    }
    
    struct State {}
    
    var initialState: State = State()
    let myPageReactor: MypageReactor
    
    init(myPageReactor: MypageReactor) {
        self.myPageReactor = myPageReactor
    }
    
}

extension DarkLightReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateMyPageDisplayModeAction(let displayMode): // 화면 모드 업데이트
            myPageReactor.action.onNext(.updateDisplayModeAction(displayMode))
            return .empty()
        }
        
    }
}

//extension DarkLightReactor {
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//        switch mutation {
//        case .updateMyPageDisplayModeMutation(let displayMode):
//            newState.myDisplayMode.displayMode = displayMode
//            switch displayMode {
//            case "다크":
//                newState.displayIntType = DisplaySectionIntType.dark.rawValue
//            case "라이트":
//                newState.displayIntType = DisplaySectionIntType.light.rawValue
//            case "시스템":
//                newState.displayIntType = DisplaySectionIntType.system.rawValue
//            default:
//                break
//            }
//        }
//        
//        return newState
//    }
//}
