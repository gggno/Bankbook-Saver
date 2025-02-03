//
//  HomeReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import Foundation
import ReactorKit

class HomeReactor: Reactor {
    
    // in
    enum Action {
        case fetchDateAction    // 날짜 불러오기
        
    }
    
    // 연산
    enum Mutation {
        case fetchDateMutation(days: [String])  // 날짜 불러오기
        
    }
    
    // out
    struct State {
        var calendarDatas: [CalendarData] = []
        var selectedDate: [String] = []
        
    }
    
    let initialState: State = State()
    
}

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchDateAction:
            // 날짜 데이터 가져오기
            let calendarDatas = getCalendarData()
            var days: [String] = []
            
            // 캘린더에 들어갈 데이터 추출
            for date in calendarDatas {
                let dateArr = date.date.split(separator: "-").map{String($0)}
                if dateArr.isEmpty {
                    days.append("")
                } else {
                    let year = dateArr[0], month = dateArr[1], day = dateArr[2]
                    days.append(day)
                }
            }
            return .just(.fetchDateMutation(days: days))
        }
    }
    
    // 현재 달의 첫째날 가져오기
    func getCurrentMonthFirstDay() -> Date? {
        print("HomeReactor - getCurrentMonthFirstDay() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        
        let today = Date()
        
        guard let range = calendar.range(of: .day, in: .month, for: today),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return nil
        }
        
        return firstDay
    }
    
    // 현재 달의 모든 날 가져오기
    func getAllDaysInCurrentMonth() -> [Date] {
        print("HomeReactor - getAllDaysInCurrentMonth() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        guard let firstDay = getCurrentMonthFirstDay() else { return [] }
        
        return (0..<calendar.range(of: .day, in: .month, for: firstDay)!.count).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstDay)
        }
    }
    
    // 캘린더에 들어갈 데이터 가공하기
    func getCalendarData() -> [CalendarData] {
        print("HomeReactor - getCalendarData() called")
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko")
        guard let firstDay = getCurrentMonthFirstDay() else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1(일) ~ 7(토)
        var calendarDatas: [CalendarData] = []
        let emptyCount = firstWeekday - 1
        
        // 첫째날 요일에 따라 위치를 맞추기 위해 앞에 빈 데이터 추가
        for _ in 0..<emptyCount {
            calendarDatas.append(CalendarData(date: ""))
        }
        
        let dates = getAllDaysInCurrentMonth()
        
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
        case .fetchDateMutation(let days): 
            newState.selectedDate = days
        }
        
        return newState
    }
}
