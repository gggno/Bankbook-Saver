//
//  NotiSettingReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/4/25.
//

import Foundation
import ReactorKit

class NotiSettingReactor: Reactor {
    
    enum Action {
        case dailyReminderAction(Bool)
        case dailyReminderExistsAction(Bool)
    }
    
    enum Mutation {
        case dailyReminderMutation(Bool)
        case dailyReminderExistsMutation(Bool)

    }
    
    struct State {
        var cellInfo: [(title: String, subTitle: String, state: Bool)] = [
            ("오늘 하루의 소비 내역을 작성해보세요!", "(매일 지정된 시간(저녁 9시)에 알립니다.)", true)
        ]
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .dailyReminderAction(let state):
            if state {  // 해제 -> 등록으로 상태 변경 함
                LocalNotiManager.shared.setDailyReminder()
            } else {    // 등록 -> 해제로 상태 변경 함
                LocalNotiManager.shared.cancelDailyReminder()
            }
            return .empty()
            
        case .dailyReminderExistsAction(let state):
            return .just(.dailyReminderExistsMutation(state))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .dailyReminderMutation(_):
            print("dailyReminderMutation")
            
        case .dailyReminderExistsMutation(let state):
            newState.cellInfo[0].state = state
        }
        
        return newState
    }
}
