//
//  HomeReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import Foundation
import ReactorKit
import RealmSwift

class HomeReactor: Reactor {
    
    // in
    enum Action {
        case fetchDataAction(count: Int)    // 날짜, 지출/수입 데이터 불러오기
    }
    
    // 연산
    enum Mutation {
        case fetchDateMutation(year: String, month: String, days: [String], dateCount: Int) // 날짜 불러오기
        case fetchThisMonthDataMutation(thisMonthDatas: [HomeDataEntity])       // 이번 달 지출/수입 모든 데이터 불러오기
        case fetchHomeDatasMutation(inOutDatas: [String: [InOutCellInfo]])      // 지출/수입 데이터 불러오기
        case fetchInOutMoneyAction(inDatas: [Int], outDatas: [Int])             // 지출/수입 금액 데이터 불러오기
    }
    
    // out
    struct State {
        // 선택한 날짜 관련 데이터
        var selectedYear: String = ""
        var selectedMonth: String = ""
        var selectedDays: [String] = []
        var selectedDateCount: Int = 0
        
        // 선택한 달의 지출/수입 관련 데이터
        var inOutData: [String: [InOutCellInfo]] = [:]
        // 선택한 달의 지출/수입 관련 모든 데이터(셀을 클릭했을 때 이용)
        var thisMonthDatas: [HomeDataEntity] = []
        
        // 선택한 날의 지출/수입 금액 데이터(calendarCollectionView에 표시하기 위해 사용)
        var inComeMoneys: [Int] = []
        var outComeMoneys: [Int] = []
    }
    
    let initialState: State = State()
    
    let realm = try! Realm()
}

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchDataAction(let dateCount):
            // 날짜 데이터 가져와서 가공하기
            let calendarDatas = getCalendarData(selectedDateCount: currentState.selectedDateCount + dateCount)
            var year: String = ""
            var month: String = ""
            var days: [String] = []
            
            // 선택한 년도, 월 데이터 추출
            let calendarLastData = calendarDatas.last!.date.split(separator: "-").map{String($0)}
            year = calendarLastData[0]
            month = calendarLastData[1]
            
            // 선택한 일 데이터(ex 1...31) 추출
            for date in calendarDatas {
                let dateArr = date.date.split(separator: "-").map{String($0)}
                if dateArr.isEmpty {
                    days.append("")
                    
                } else {
                    let day = dateArr[2]
                    
                    days.append(day)
                }
            }
            
            // 지출/수입 데이터 추출
            let allHomeDatas = realm.objects(HomeDataEntity.self)
                .sorted(byKeyPath: "purposeDate", ascending: true)
            
            // 이번달 홈 데이터 추출
            let thisMonthHomeDatas: [HomeDataEntity] = allHomeDatas.filter {
                let calendar = Calendar.current
                let filterYear = calendar.component(.year, from: $0.purposeDate)
                let filterMonth = calendar.component(.month, from: $0.purposeDate)
                
                return filterYear == Int(year)! && filterMonth == Int(month)!
            }.map { $0 }
            
            var filterInOutDatas: [String: [InOutCellInfo]] = [:]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d일 EEEE"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            
            for data in thisMonthHomeDatas {
                let purposeDate = dateFormatter.string(from: data.purposeDate)
                let emoji = data.transactionType == "수입"
                ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                
                let money = data.transactionType == "수입" ? data.money : "-\(data.money)"
                let detailUse = data.purposeText
                
                if filterInOutDatas[purposeDate] == nil {
                    filterInOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                } else {
                    filterInOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                }
            }
            
            var emptyCnt = 0
            var exsitCnt = 0
            for date in calendarDatas {
                let dateArr = date.date.split(separator: "-").map{String($0)}
                if dateArr.isEmpty {
                    emptyCnt += 1
                } else {
                    exsitCnt += 1
                }
            }
            
            var filterInDatas = Array(repeating: 0, count: emptyCnt + exsitCnt)   // 수입 데이터
            var filterOutDatas = Array(repeating: 0, count: emptyCnt + exsitCnt)  // 지출 데이터
            
            for data in filterInOutDatas {
                if let day = data.key.components(separatedBy: "일").first {
                    // 공백이 포함된 달력의 인덱스 구하기
                    let filterIndex = emptyCnt + Int(day)! - 1
                    for i in data.value {
                        if i.transactionType == "수입" {
                            filterInDatas[filterIndex] += Int(i.money)!
                        } else if i.transactionType == "지출" {
                            filterOutDatas[filterIndex] += Int(i.money)!
                        }
                    }
                }
            }
            
            
            return Observable.concat([
                // 날짜 데이터
                .just(.fetchDateMutation(year: year, month: month, days: days, dateCount: currentState.selectedDateCount + dateCount)),
                // 이번달 지출/수입 모든 데이터
                .just(.fetchThisMonthDataMutation(thisMonthDatas: thisMonthHomeDatas)),
                // 로컬디비에서 지출/수입 데이터
                .just(.fetchHomeDatasMutation(inOutDatas: filterInOutDatas)),
                // 지출/수입 금액 데이터
                .just(.fetchInOutMoneyAction(inDatas: filterInDatas, outDatas: filterOutDatas))
            ])
        }
    }
    
    // 선택한 달의 첫째날 가져오기
    func getMonthFirstDay(selectedDateCount: Int) -> Date? {
        print("HomeReactor - getCurrentMonthFirstDay() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        
        guard let selectedDate = calendar.date(byAdding: .month, value: selectedDateCount, to: Date()) else {return nil}
        
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return nil
        }
        
        return firstDay
    }
    
    // 선택한 달의 모든 날 가져오기
    func getAllDaysInMonth(selectedDateCount: Int) -> [Date] {
        print("HomeReactor - getAllDaysInCurrentMonth() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        
        guard let firstDay = getMonthFirstDay(selectedDateCount: selectedDateCount) else { return [] }
        
        return (0..<calendar.range(of: .day, in: .month, for: firstDay)!.count).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstDay) }
    }
    
    // 캘린더에 들어갈 데이터 가공하기
    func getCalendarData(selectedDateCount: Int) -> [CalendarData] {
        print("HomeReactor - getCalendarData() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        
        guard let firstDay = getMonthFirstDay(selectedDateCount: selectedDateCount) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1(일) ~ 7(토)
        var calendarDatas: [CalendarData] = []
        let emptyCount = firstWeekday - 1
        
        // 첫째날 요일에 따라 위치를 맞추기 위해 앞에 빈 데이터 추가
        for _ in 0..<emptyCount {
            calendarDatas.append(CalendarData(date: ""))
        }
        
        let dates = getAllDaysInMonth(selectedDateCount: selectedDateCount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        for date in dates {
            let dateString = dateFormatter.string(from: date)
            calendarDatas.append(CalendarData(date: dateString))
        }
        
        return calendarDatas
    }
    
}

extension HomeReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchDateMutation(let year, let month, let days, let dateCount):
            newState.selectedYear = year
            newState.selectedMonth = month
            newState.selectedDays = days
            newState.selectedDateCount = dateCount
            
        case .fetchThisMonthDataMutation(thisMonthDatas: let thisMonthDatas):
            newState.thisMonthDatas = thisMonthDatas
            
        case .fetchHomeDatasMutation(let inOutDatas):
            newState.inOutData = inOutDatas
            
        case .fetchInOutMoneyAction(inDatas: let inDatas, outDatas: let outDatas):
            newState.inComeMoneys = inDatas
            newState.outComeMoneys = outDatas
        }
        
        return newState
    }
}
