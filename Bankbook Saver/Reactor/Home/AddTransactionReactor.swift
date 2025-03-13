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
        case removeExistDataAction(String?)      // 거래 내역을 수정할 경우 기존 데이터는 삭제
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
        var transactionId: String = ""
        var transactionType: String = ""
        var moneyText: String = ""
        var purposeText: String = ""
        var purposeDate: Date = Date()
        var repeatState: Bool = false
        var expenseKind: Int = 0
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
        
        case .addHomeDataAction:    // 확인 버튼을 탭 했을 때
            return .just(.addHomeDataMutation)
            
        case .removeExistDataAction(let id):// 등록된 거래내역 데이터 삭제하기(realm에서 삭제, 정기 알림도 삭제 후 다시
            guard let id = id, let objectId = try? ObjectId(string: id) else { return .empty() }
            
            // 기존에 등록된 거래내역 데이터 삭제
            try! realm.write {
                if let homeData = realm.objects(HomeDataEntity.self).filter("_id == %@", objectId).first {
                    realm.delete(homeData)
                }
            }
            
            // 기존에 등록된 정기 알림 삭제
            LocalNotiManager.shared.cancelRepeatPaymentNoti(id: id)
            LocalNotiManager.shared.cancelRepeatIncomeNoti(id: id)
            
            return .empty()
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
            print("date: \(date)")
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
                
                // 정기 구독 결제일 알림 등록
                if currentState.repeatState {
                    if homeData.transactionType == "지출" {
                        LocalNotiManager.shared.setRepeatPayment(id: homeData._id.stringValue,
                                                                 purposeText: homeData.purposeText,
                                                                 purposeDate: homeData.purposeDate)
                    } else if homeData.transactionType == "수입" {
                        LocalNotiManager.shared.setRepeatIncome(id: homeData._id.stringValue,
                                                                purposeText: homeData.purposeText,
                                                                purposeDate: homeData.purposeDate)
                    }
                    
                }
            }
        }
        
        return newState
    }
}
