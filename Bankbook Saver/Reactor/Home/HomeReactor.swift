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
        case fetchDateAction(count: Int)    // 날짜 불러오기
    }
    
    // 연산
    enum Mutation {
        case fetchDateMutation(year: String, month: String, days: [String], dateCount: Int)     // 날짜 불러오기
    }
    
    // out
    struct State {
        var selectedDateCount: Int = 0
        
        var selectedYear: String = ""
        var selectedMonth: String = ""
        var selectedDays: [String] = []
    }
    
    let initialState: State = State()
}

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchDateAction(let dateCount):
            // 날짜 데이터 가져오기
            let calendarDatas = getCalendarData(selectedDateCount: currentState.selectedDateCount + dateCount)
            var year: String = ""
            var month: String = ""
            var days: [String] = []
            
            // 캘린더에 들어갈 년, 월 데이터 추출
            let calendarLastData = calendarDatas.last!.date.split(separator: "-").map{String($0)}
            year = calendarLastData[0]
            month = calendarLastData[1]
            
            // 캘린더에 들어갈 일 데이터(ex 1...31) 추출
            for date in calendarDatas {
                let dateArr = date.date.split(separator: "-").map{String($0)}
                if dateArr.isEmpty {
                    days.append("")
                } else {
                    let day = dateArr[2]
                    
                    days.append(day)
                }
            }
            return .just(.fetchDateMutation(year: year, month: month, days: days, dateCount: currentState.selectedDateCount + dateCount))
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
        }
        
        return newState
    }
}
