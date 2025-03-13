//
//  SearchHomeDataReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/12/25.
//

import Foundation
import ReactorKit
import RealmSwift

class SearchHomeDataReactor: Reactor {
    
    enum Action {
        case updateSearchTextAction(String)
    }
    
    enum Mutation {
        case updateSearchTextMutation(String)
        case updateInOutDatas([String: [InOutCellInfo]])
        case fetchSearchedDataMutation([HomeDataEntity])
    }
    
    struct State {
        var searchText: String = ""
        // 검색된 데이터
        var inOutDatas: [String: [InOutCellInfo]] = [:]
        
        var searchedHomeDatas: [HomeDataEntity] = []
    }
    
    let initialState: State = State()
    
    let realm = try! Realm()
}

extension SearchHomeDataReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateSearchTextAction(let text):
            // 지출/수입 데이터 추출
            let allHomeDatas = realm.objects(HomeDataEntity.self)
                .sorted(byKeyPath: "purposeDate", ascending: true)
            
            // 검색한 홈 데이터 추출
            let searchedHomeDatas: [HomeDataEntity] = allHomeDatas.filter {
                return $0.purposeText.contains(text)
            }.map { $0 }
            
            var filterInOutDatas: [String: [InOutCellInfo]] = [:]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            
            for data in searchedHomeDatas {
                let purposeDate = dateFormatter.string(from: data.purposeDate)
                let emoji = data.transactionType == "수입"
                ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                let detailUse = data.purposeText
                
                if filterInOutDatas[purposeDate] == nil {
                    filterInOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                } else {
                    filterInOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                }
            }
            
            return Observable.concat([
                .just(.updateSearchTextMutation(text)),
                .just(.updateInOutDatas(filterInOutDatas)),
                .just(.fetchSearchedDataMutation(searchedHomeDatas))
            ])
        }
    }
}


extension SearchHomeDataReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateSearchTextMutation(let text):
            newState.searchText = text
            
        case .updateInOutDatas(let inOutDatas):
            newState.inOutDatas = inOutDatas
            
        case .fetchSearchedDataMutation(let searchedDatas):
            newState.searchedHomeDatas = searchedDatas
        }
        
        return newState
    }
}
