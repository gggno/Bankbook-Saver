//
//  AddTransactionReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 2/11/25.
//

import Foundation
import ReactorKit
import RealmSwift

class AddTransactionReactor: Reactor {
    
    // in
    enum Action {
        case updateTransactionTypeAction(String)      // 거래 내역 타입
        case updateMoneyTextAction(String)      // 금액 입력
        case updatePurposeTextAction(String)    // 지출/수입처 입력
        case updatePurposeDateAction(Date)      // 일시
        case repeatStateAction(Bool)            // 반복
        case expenseKindAction(Int)             // 지출수단
        case updateCategoryIndexAction(Int)     // 카테고리
        case updateMemoTextAction(String)       // 메모 입력
        
        case addHomeDataAction                  // 로컬에 저장
    }
    
    // 연산
    enum Mutation {
        case updateTransactionTypeMutation(String) // 거래 내역 타입
        case updateMoneyTextMutation(String)        // 금액 입력
        case updatePurposeTextMutation(String)      // 지출/수입처 입력
        case updatePurposeDateMutation(Date)        // 일시
        case repeatStateMutation(Bool)              // 반복
        case expenseKindMutaion(Int)                // 지출수단
        case updateCategoryIndexMutation(Int)       // 카테고리
        case updateMemoTextMutation(String)         // 메모 입력
        
        case addHomeDataMutation                    // 로컬에 저장
    }
     
    // out
    struct State {
        var transactionType: String = ""
        var moneyText: String = ""
        var purposeText: String = ""
        var purposeDate: Date = Date()
        var repeatState: Bool = false
        var expenseKind: Int = 0
        var categoryDatas = CategoryType.allCases
        var selectedCategoryIndex: Int = 0
        var memoText: String = ""
    }
    
    let initialState: State = State()
    
    let realm = try! Realm()
}

extension AddTransactionReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateTransactionTypeAction(let type):
            return .just(.updateTransactionTypeMutation(type))
        
        case .updateMoneyTextAction(let text):
            return .just(.updateMoneyTextMutation(text))
        
        case .updatePurposeTextAction(let text):
            return .just(.updatePurposeTextMutation(text))
        
        case .updatePurposeDateAction(let date):
            return .just(.updatePurposeDateMutation(date))
        
        case .updateMemoTextAction(let text):
            return .just(.updateMemoTextMutation(text))
        
        case .repeatStateAction(let state):
            return .just(.repeatStateMutation(state))
            
        case .expenseKindAction(let kind):
            return .just(.expenseKindMutaion(kind))
        
        case .updateCategoryIndexAction(let index):
            return .just(.updateCategoryIndexMutation(index))
        
        case .addHomeDataAction:    // 지출 확인 버튼을 탭 했을 때
            return .just(.addHomeDataMutation)
        }
    }
}

extension AddTransactionReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateTransactionTypeMutation(let type):
            print(type)
            newState.transactionType = type
            
        case .updateMoneyTextMutation(let text):
            print(text)
            newState.moneyText = text
        
        case .updatePurposeTextMutation(let text):
            print(text)
            newState.purposeText = text
            
        case .updatePurposeDateMutation(let date):
            print(date)
            newState.purposeDate = date
        
        case .updateMemoTextMutation(let text):
            print(text)
            newState.memoText = text
        
        case .repeatStateMutation(let state):
            print("state: \(state)")
            newState.repeatState = state
        
        case .expenseKindMutaion(let kind):
            print(kind)
            newState.expenseKind = kind
            
        case .updateCategoryIndexMutation(let index):
            print(index)
            newState.selectedCategoryIndex = index
        
        case .addHomeDataMutation:
            // realm에 입력한 지출/수입 데이터 저장
            try! realm.write {
                let homeData = HomeDataEntity()
                
                homeData.transactionType = currentState.transactionType
                homeData.money = currentState.moneyText
                homeData.purposeText = currentState.purposeText
                homeData.purposeDate = currentState.purposeDate
                homeData.repeatState = currentState.repeatState
                homeData.expenseKind = currentState.expenseKind
                homeData.selectedCategoryIndex = currentState.selectedCategoryIndex
                homeData.memoText = currentState.memoText
                
                realm.add(homeData)
                
                // 추후 수정하는 로직에서 한번 더 살펴봐야 함
                // 정기 구독 결제일 알림 등록/해제
                if currentState.repeatState {
                    LocalNotiManager.shared.setRepeatPayment(id: homeData._id.stringValue,
                                                             purposeText: homeData.purposeText,
                                                             purposeDate: homeData.purposeDate)
                    
                } else {
                    LocalNotiManager.shared.cancelRepeatPayment(id: homeData._id.stringValue)
                }
            }
        }
        
        return newState
    }
}
