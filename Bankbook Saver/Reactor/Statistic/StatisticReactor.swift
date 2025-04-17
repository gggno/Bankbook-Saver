//
//  StatisticReactor.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import Foundation
import ReactorKit
import RealmSwift

class StatisticReactor: Reactor {
    
    enum Action {
        case fetchDbDataAction                  // 로컬 DB에 저장된 데이터 불러오기
        case updateSegmentIndexAction(Int)      // 세그먼트 컨트롤 인덱스 가져오기
        case segmentControlIndexResetAction     // 세크먼트 컨트롤 인덱스 2로 초기화
        case moveToDateAction(Int)
    }
    
    enum Mutation {
        case fetchDbDataMutation([HomeDataEntity])
        case updateSegmentIndexMutation(Int)
        case segmentControlIndexResetMutation
        case selectedDateCountResetMutation       // 선택한 날짜 카운트 0으로 초기화
        case updateDisplayDatasMutation(String, String, String, String, [BarChartInfo], [PieChartInfo], [String: [InOutCellInfo]])
        case updateSelectedDateCountMutation(Int)
    }
    
    struct State {
        var dbDatas: [HomeDataEntity] = []
        
        var selectedIndex = 2                           // 세그먼트 컨트롤 인덱스
        var selectedDateCount: Int = 0                  // 날짜 변경 카운트
        
        // 화면에 보여질 DisplayDatas
        var dateText: String = ""                       // 날짜
        var outComeMoneyText: String = ""               // 총 지출
        var inComeMoneyText: String = ""                // 총 수입
        var lastSixMonthText: String = ""               // 지난달과 지출 비교
        var barChartDatas: [BarChartInfo] = []          // 막대 그래프 데이터
        var pieChartDatas: [PieChartInfo] = []          // 원 그래프 데이터
        var inOutDatas: [String: [InOutCellInfo]] = [:]  // 지출/수입 데이터
    }
    
    let initialState: State = State()
    
    let realm = try! Realm()
}

extension StatisticReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .fetchDbDataAction:
            print("fetchDbDataAction")
            
            let allDbDatas = Array(realm.objects(HomeDataEntity.self))
            return .just(.fetchDbDataMutation(allDbDatas))
            
        case .updateSegmentIndexAction(let selectedIndex):
            print("updateSegmentIndexAction")
            
            let today = Date()
            
            let calendar = Calendar.current
            let todayYear = calendar.component(.year, from: today)
            let todayMonth = calendar.component(.month, from: today)
            let todayDay = calendar.component(.day, from: today)
            
            var dateText: String = ""
            var outComeMoneyText: String = ""
            var inComeMoneyText: String = ""
            var lastCompareText: String = ""
            var barChartDatas: [BarChartInfo] = []
            var pieChartDatas: [PieChartInfo] = []
            var inOutDatas: [String: [InOutCellInfo]] = [:]
                        
            switch selectedIndex {
            case 0: // 일별
                print("case 0: 일별")
                let allDbDatas = self.currentState.dbDatas

                var dayFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == todayYear && filterMonth == todayMonth && filterDay == todayDay
                }
                
                // 오늘 시작 시간
                let startToday = calendar.startOfDay(for: today)
                let endDay = calendar.range(of: .day, in: .month, for: today)?.count
                
                // 반복되는 데이터 추출
                let repeatDatas = allDbDatas.filter {
                    return $0.purposeDate < startToday && $0.repeatState == true
                }
                
                for data in repeatDatas {
                    var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                    dateComponents.year = todayYear
                    dateComponents.month = todayMonth
                    
                    // 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                    let filterDay = calendar.component(.day, from: data.purposeDate)
                    
                    if let endDay = endDay {
                        // 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                        if filterDay > endDay && todayDay == endDay {
                            dateComponents.day = endDay
                        } else if filterDay == todayDay {   // 현재 달의 마지막 날보다 높지 않으면 현재 날로 할당
                            dateComponents.day = todayDay
                        } else {
                            continue
                        }
                    }
                    
                    // 반복 데이터의 날짜를 오늘 날짜로 변경 후 dayFilterDatas에 넣어주기
                    if let changedDate = calendar.date(from: dateComponents) {
                        let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                        dayFilterDatas.append(changedRepeatData)
                    }
                }
                
                // 날짜
                dateText = "\(todayMonth)월 \(todayDay)일"
                
                // 총 지출
                outComeMoneyText = String(dayFilterDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(dayFilterDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 어제와 지출 비교
                let lastDate = calendar.date(byAdding: .day, value: -1, to: today)!
                
                let lastYear = calendar.component(.year, from: lastDate)
                let lastMonth = calendar.component(.month, from: lastDate)
                let lastDay = calendar.component(.day, from: lastDate)
                
                var lastDayFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == lastYear && filterMonth == lastMonth && filterDay == lastDay
                }
                
                // 오늘 시작 시간
                let startLastDay = calendar.startOfDay(for: lastDate)
                let endLastDay = calendar.range(of: .day, in: .month, for: lastDate)?.count
                
                // 반복되는 데이터 추출
                let lastRepeatDatas = allDbDatas.filter {
                    return $0.purposeDate < startLastDay && $0.repeatState == true
                }
                
                for data in lastRepeatDatas {
                    var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                    dateComponents.year = lastYear
                    dateComponents.month = lastMonth
                    
                    // 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                    let filterDay = calendar.component(.day, from: data.purposeDate)
                    
                    if let endDay = endLastDay {
                        // 지금이 현재 달의 마지막 날이고, 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                        if filterDay > endDay && lastDay == endDay {
                            dateComponents.day = endDay
                        } else if filterDay == lastDay { // 현재 달의 마지막 날보다 높지 않으면 현재 날로 할당
                            dateComponents.day = lastDay
                        } else {
                            continue
                        }
                    }
                    
                    // 반복 데이터의 날짜를 오늘 날짜로 변경 후 lastDayFliterDatas에 넣어주기
                    if let changedDate = calendar.date(from: dateComponents) {
                        let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                        lastDayFliterDatas.append(changedRepeatData)
                    }
                }
                
                // 오늘 지출 데이터 필터링
                let thisDayOutMoney = dayFilterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                // 어제 지출 데이터 필터링
                let lastDayOutMoney = lastDayFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                if thisDayOutMoney > lastDayOutMoney {          // 이번주에 더 많이 지출했을 때
                    lastCompareText = "오늘 \(thisDayOutMoney - lastDayOutMoney)원 더 썼어요"
                } else if thisDayOutMoney < lastDayOutMoney {   // 지난주에 더 많이 지출했을 때
                    lastCompareText = "어제 \(lastDayOutMoney - thisDayOutMoney)원 더 썼어요"
                } else {                                            // 이번주와 지난주 지출이 같을 때
                    lastCompareText = "어제 지출과 같아요"
                }
                
                for value in -6...0 {
                    let barChartDate = calendar.date(byAdding: .day, value: value, to: today)!
                    let barChartYear = calendar.component(.year, from: barChartDate)
                    let barChartMonth = calendar.component(.month, from: barChartDate)
                    let barChartDay = calendar.component(.day, from: barChartDate)
                    
                    var barChartDayFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        let filterDay = calendar.component(.day, from: $0.purposeDate)
                        
                        return filterYear == barChartYear && filterMonth == barChartMonth && filterDay == barChartDay
                    }
                    
                    // 오늘 날의 시작 시간
                    let startBarChartDay = calendar.startOfDay(for: barChartDate)
                    // 선택한 날의 날 개수
                    let endBarChartDay = calendar.range(of: .day, in: .month, for: barChartDate)?.count
                    
                    // 반복되는 데이터 추출
                    let barChartRepeatDatas = allDbDatas.filter {
                        return $0.purposeDate < startBarChartDay && $0.repeatState == true
                    }
                    
                    for data in barChartRepeatDatas {
                        var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                        dateComponents.year = barChartYear
                        dateComponents.month = barChartMonth
                        
                        // 선택한 달의 마지막 날보다 높으면 선택한 달의 마지막 날로 할당
                        let filterDay = calendar.component(.day, from: data.purposeDate)
                        
                        if let endDay = endBarChartDay {
                            // 지금이 선택한 달의 마지막 날이고, 선택한 달의 마지막 날보다 높으면 선택한 달의 마지막 날로 할당
                            if filterDay > endDay && barChartDay == endDay {
                                dateComponents.day = endDay
                            } else if filterDay == barChartDay { // 선택한 달의 마지막 날보다 높지 않으면 선택한 날로 할당
                                dateComponents.day = barChartDay
                            } else {
                                continue
                            }
                        }
                        
                        // 반복 데이터의 날짜를 선택한 날짜로 변경 후 barChartDayFliterDatas에 넣어주기
                        if let changedDate = calendar.date(from: dateComponents) {
                            let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                            barChartDayFliterDatas.append(changedRepeatData)
                        }
                    }
                    
                    let barChartDayOutMoney = barChartDayFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartDay)일", spendMoney: barChartDayOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = dayFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = Int(data.money)!
                    } else {
                        dic[category]! += Int(data.money)!
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE" 
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in dayFilterDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
            case 1: // 주별
                print("case 1: 주별")
                let allDbDatas = self.currentState.dbDatas
                
                // 주별 일주일의 시작과 끝 구하기
                let todayWeekday = calendar.component(.weekday, from: today)
                let startDayInt = (todayWeekday == 1) ? 1 : -(todayWeekday - 1)
                let endDayInt = (todayWeekday == 7) ? 7 : (7 - todayWeekday)
                
                var startWeekDay = calendar.date(byAdding: .day, value: startDayInt, to: today)!
                startWeekDay = calendar.startOfDay(for: startWeekDay)
                
                var endWeekDay = calendar.date(byAdding: .day, value: endDayInt, to: today)!
                endWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endWeekDay))!
                
                var weekOfMonthDbDatas = allDbDatas.filter { startWeekDay <= $0.purposeDate && endWeekDay >= $0.purposeDate }
                
                // 1. 반복 데이터 필터링
                let repeatDatas = allDbDatas.filter {
                    $0.purposeDate < startWeekDay &&
                    $0.repeatState == true &&
                    repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startWeekDay, endWeek: endWeekDay, calendar: calendar).map { $0 >= startWeekDay && $0 <= endWeekDay } ?? false
                }
                
                // 2. 매핑된 날짜로 새로운 데이터 생성 후 weekOfMonthDbDatas에 추가
                weekOfMonthDbDatas.append(contentsOf: appendWeekOfRepeatDatas(
                    repeatDatas: repeatDatas,
                    startWeek: startWeekDay,
                    endWeek: endWeekDay,
                    calendar: calendar
                ))
                
                // 날짜
                let weekDateFormatter = DateFormatter()
                weekDateFormatter.dateFormat = "yyyy.MM.dd"
                
                dateText = "\(weekDateFormatter.string(from: startWeekDay)) ~ \(weekDateFormatter.string(from: endWeekDay))"
                
                //총 지출
                outComeMoneyText = String(weekOfMonthDbDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(weekOfMonthDbDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 지난주과 지출 비교
                var startLastWeekDay = calendar.date(byAdding: .day, value: startDayInt - 7, to: today)!
                startLastWeekDay = calendar.startOfDay(for: startLastWeekDay)
                
                var endLastWeekDay = calendar.date(byAdding: .day, value: endDayInt - 7, to: today)!
                endLastWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endLastWeekDay))!
                
                var lastWeekOfMonthFliterDatas = allDbDatas.filter { startLastWeekDay <= $0.purposeDate && endLastWeekDay >= $0.purposeDate }
                
                // 1. 반복 데이터 필터링
                let lastWeekOfRepeatDatas = allDbDatas.filter {
                    $0.purposeDate < startLastWeekDay &&
                    $0.repeatState == true &&
                    repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startLastWeekDay, endWeek: endLastWeekDay, calendar: calendar).map { $0 >= startLastWeekDay && $0 <= endLastWeekDay } ?? false
                }
                
                // 2. 매핑된 날짜로 새로운 데이터 생성 후 lastWeekOfMonthFliterDatas에 추가
                lastWeekOfMonthFliterDatas.append(contentsOf: appendWeekOfRepeatDatas(
                    repeatDatas: lastWeekOfRepeatDatas,
                    startWeek: startLastWeekDay,
                    endWeek: endLastWeekDay,
                    calendar: calendar
                ))
                                
                let thisMonthOutMoney = weekOfMonthDbDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                let lastMonthOutMoney = lastWeekOfMonthFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                if thisMonthOutMoney > lastMonthOutMoney {          // 이번주에 더 많이 지출했을 때
                    lastCompareText = "이번주에 \(thisMonthOutMoney - lastMonthOutMoney)원 더 썼어요"
                } else if thisMonthOutMoney < lastMonthOutMoney {   // 지난주에 더 많이 지출했을 때
                    lastCompareText = "지난주에 \(lastMonthOutMoney - thisMonthOutMoney)원 더 썼어요"
                } else {                                            // 이번주와 지난주 지출이 같을 때
                    lastCompareText = "지난주 지출과 같아요"
                }
                
                // 막대 그래프(최근 4주 지출)
                for value in -3...0 {
                    var startBarWeekDay = calendar.date(byAdding: .day, value: startDayInt + (value * 7), to: today)!
                    startBarWeekDay = calendar.startOfDay(for: startBarWeekDay)
                    
                    var endBarWeekDay = calendar.date(byAdding: .day, value: endDayInt + (value * 7), to: today)!
                    endBarWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endBarWeekDay))!
                    
                    var barChartWeekOfMonthFliterDatas = allDbDatas.filter { startBarWeekDay <= $0.purposeDate && endBarWeekDay >= $0.purposeDate }
                    
                    // 1. 반복 데이터 필터링
                    let lastWeekOfBarRepeatDatas = allDbDatas.filter {
                        $0.purposeDate < startBarWeekDay &&
                        $0.repeatState == true &&
                        repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startBarWeekDay, endWeek: endBarWeekDay, calendar: calendar).map { $0 >= startBarWeekDay && $0 <= endBarWeekDay } ?? false
                    }
                    
                    // 2. 매핑된 날짜로 새로운 데이터 생성 후 barChartWeekOfMonthFliterDatas에 추가
                    barChartWeekOfMonthFliterDatas.append(contentsOf: appendWeekOfRepeatDatas(
                        repeatDatas: lastWeekOfBarRepeatDatas,
                        startWeek: startBarWeekDay,
                        endWeek: endBarWeekDay,
                        calendar: calendar
                    ))
                    
                    let barChartWeekOfMonthOutMoney = barChartWeekOfMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    let barDateFormatter = DateFormatter()
                    barDateFormatter.dateFormat = "MM.dd"
                    
                    barChartDatas.append(BarChartInfo(month: "\(barDateFormatter.string(from: startBarWeekDay)) ~\n\(barDateFormatter.string(from: endBarWeekDay))", spendMoney: barChartWeekOfMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = weekOfMonthDbDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = Int(data.money)!
                    } else {
                        dic[category]! += Int(data.money)!
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in weekOfMonthDbDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
                
            case 2: // 월별
                print("case 2: 월별")
                let allDbDatas = self.currentState.dbDatas
                
                var monthFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == todayYear && filterMonth == todayMonth
                }
                
                let yearMonthFormatter = DateFormatter()
                yearMonthFormatter.dateFormat = "yyyy-MM"
                yearMonthFormatter.locale = Locale(identifier: "ko_KR")
                
                // 매월 반복 데이터 추출
                let repeatDatas: [HomeDataEntity] = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    
                    if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                       let todayDate = yearMonthFormatter.date(from: "\(todayYear)-\(todayMonth)") {
                        return todayDate > filterDate && $0.repeatState == true
                    } else {
                        return false
                    }
                }.map { $0 }
                
                monthFilterDatas.append(contentsOf: appendMonthRepeatDatas(year: todayYear, month: todayMonth, repeatDatas: repeatDatas, calendar: calendar))
                
                // 날짜
                dateText = "\(todayYear)년 \(todayMonth)월"
                
                //총 지출
                outComeMoneyText = String(monthFilterDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(monthFilterDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 지난달과 지출 비교
                let lastDate = calendar.date(byAdding: .month, value: -1, to: today)!
                let lastYear = calendar.component(.year, from: lastDate)
                let lastMonth = calendar.component(.month, from: lastDate)
                
                var lastMonthFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == lastYear && filterMonth == lastMonth
                }
                
                // 매월 반복 데이터 추출
                let lastRepeatDatas: [HomeDataEntity] = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    
                    if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                       let selectedDate = yearMonthFormatter.date(from: "\(lastYear)-\(lastMonth)") {
                        return selectedDate > filterDate && $0.repeatState == true
                    } else {
                        return false
                    }
                }.map { $0 }
                
                lastMonthFliterDatas.append(contentsOf: appendMonthRepeatDatas(year: lastYear, month: lastMonth, repeatDatas: lastRepeatDatas, calendar: calendar))
                
                let thisMonthOutMoney = monthFilterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                let lastMonthOutMoney = lastMonthFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                if thisMonthOutMoney > lastMonthOutMoney {          // 이번달에 더 많이 지출했을 때
                    let money = (thisMonthOutMoney - lastMonthOutMoney).withComma
                    lastCompareText = "이번 달에 \(money)원 더 썼어요"
                } else if thisMonthOutMoney < lastMonthOutMoney {   // 지난달에 더 많이 지출했을 때
                    let money = (lastMonthOutMoney - thisMonthOutMoney).withComma
                    lastCompareText = "지난 달에 \(money)원 더 썼어요"
                } else {                                            // 이번달과 지난달 지출이 같을 때
                    lastCompareText = "지난 달 지출과 같아요"
                }
                
                // 막대 그래프(최근 6개월 지출)
                for value in -5...0 {
                    let barChartDate = calendar.date(byAdding: .month, value: value, to: today)!
                    let barChartYear = calendar.component(.year, from: barChartDate)
                    let barChartMonth = calendar.component(.month, from: barChartDate)
                    
                    var barChartMonthFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        return filterYear == barChartYear && filterMonth == barChartMonth
                    }
                    
                    // 매월 반복 데이터 추출
                    let repeatBarDatas: [HomeDataEntity] = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        
                        if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                           let selectedDate = yearMonthFormatter.date(from: "\(barChartYear)-\(barChartMonth)") {
                            return selectedDate > filterDate && $0.repeatState == true
                        } else {
                            return false
                        }
                    }.map { $0 }
                    
                    barChartMonthFliterDatas.append(contentsOf: appendMonthRepeatDatas(year: barChartYear, month: barChartMonth, repeatDatas: repeatBarDatas, calendar: calendar))
                    
                    let barChartMonthOutMoney = barChartMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartMonth)월", spendMoney: barChartMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = monthFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = data.money.withOutComma
                    } else {
                        dic[category]! += data.money.withOutComma
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in monthFilterDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : "-\(data.money)"
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
            default:
                break
            }
            
            return Observable.concat([
                .just(.updateSegmentIndexMutation(selectedIndex)),
                .just(.updateDisplayDatasMutation(dateText, outComeMoneyText, inComeMoneyText, lastCompareText, barChartDatas, pieChartDatas, inOutDatas)),
                .just(.selectedDateCountResetMutation)
            ])
        
        
        case .segmentControlIndexResetAction:
            return .just(.segmentControlIndexResetMutation)
        
        case .moveToDateAction(let count):
            
            let calendar = Calendar.current
            let today = Date()
            var selectedDate = Date()
            
            switch currentState.selectedIndex {
            case 0:
                selectedDate = calendar.date(byAdding: .day, value: count, to: today)!

            case 1:
                selectedDate = calendar.date(byAdding: .day, value: 7 * count, to: today)!
                
            case 2:
                selectedDate = calendar.date(byAdding: .month, value: count, to: today)!
                
            default:
                print("default")
            }
            
            let selectedDayYear = calendar.component(.year, from: selectedDate)
            let selectedDayMonth = calendar.component(.month, from: selectedDate)
            let selectedDayWeekOfMonth = calendar.component(.weekOfMonth, from: selectedDate)
            let selectedDayDay = calendar.component(.day, from: selectedDate)
            
            print("selectedDate: \(selectedDate)")
            print("selectedDayWeekOfMonth: \(selectedDayWeekOfMonth)")
            var dateText: String = ""
            var outComeMoneyText: String = ""
            var inComeMoneyText: String = ""
            var lastCompareText: String = ""
            var barChartDatas: [BarChartInfo] = []
            var pieChartDatas: [PieChartInfo] = []
            var inOutDatas: [String: [InOutCellInfo]] = [:]
            
            switch currentState.selectedIndex {
            case 0: // 일별
                print("case 0: 일별")
                let allDbDatas = self.currentState.dbDatas

                var dayFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == selectedDayYear && filterMonth == selectedDayMonth && filterDay == selectedDayDay
                }
                
                // 오늘 시작 시간
                let startSelectedDay = calendar.startOfDay(for: selectedDate)
                let endSelectedDay = calendar.range(of: .day, in: .month, for: selectedDate)?.count
                
                // 반복되는 데이터 추출
                let repeatDatas = allDbDatas.filter {
                    return $0.purposeDate < startSelectedDay && $0.repeatState == true
                }
                
                for data in repeatDatas {
                    var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                    dateComponents.year = selectedDayYear
                    dateComponents.month = selectedDayMonth
                    
                    // 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                    let filterDay = calendar.component(.day, from: data.purposeDate)
                    
                    if let endDay = endSelectedDay {
                        // 지금이 현재 달의 마지막 날이고, 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                        if filterDay > endDay && selectedDayDay == endDay {
                            dateComponents.day = endDay
                        } else if filterDay == selectedDayDay { // 현재 달의 마지막 날보다 높지 않으면 현재 날로 할당
                            dateComponents.day = selectedDayDay
                        } else {
                            continue
                        }
                    }
                    
                    // 반복 데이터의 날짜를 오늘 날짜로 변경 후 dayFilterDatas에 넣어주기
                    if let changedDate = calendar.date(from: dateComponents) {
                        let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                        dayFilterDatas.append(changedRepeatData)
                    }
                }
                
                // 날짜
                dateText = "\(selectedDayMonth)월 \(selectedDayDay)일"
                
                // 총 지출
                outComeMoneyText = String(dayFilterDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(dayFilterDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 어제와 지출 비교
                let lastDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
                
                let lastYear = calendar.component(.year, from: lastDate)
                let lastMonth = calendar.component(.month, from: lastDate)
                let lastDay = calendar.component(.day, from: lastDate)
                
                var lastDayFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == lastYear && filterMonth == lastMonth && filterDay == lastDay
                }
                
                // 오늘 시작 시간
                let startLastDay = calendar.startOfDay(for: lastDate)
                let endLastDay = calendar.range(of: .day, in: .month, for: lastDate)?.count
                
                // 반복되는 데이터 추출
                let lastRepeatDatas = allDbDatas.filter {
                    return $0.purposeDate < startLastDay && $0.repeatState == true
                }
                
                for data in lastRepeatDatas {
                    var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                    dateComponents.year = lastYear
                    dateComponents.month = lastMonth
                    
                    // 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                    let filterDay = calendar.component(.day, from: data.purposeDate)
                    
                    if let endDay = endLastDay {
                        // 지금이 현재 달의 마지막 날이고, 현재 달의 마지막 날보다 높으면 현재 달의 마지막 날로 할당
                        if filterDay > endDay && lastDay == endDay {
                            dateComponents.day = endDay
                        } else if filterDay == lastDay { // 현재 달의 마지막 날보다 높지 않으면 현재 날로 할당
                            dateComponents.day = lastDay
                        } else {
                            continue
                        }
                    }
                    
                    // 반복 데이터의 날짜를 오늘 날짜로 변경 후 lastDayFliterDatas에 넣어주기
                    if let changedDate = calendar.date(from: dateComponents) {
                        let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                        lastDayFliterDatas.append(changedRepeatData)
                    }
                }
                
                // 오늘 지출 데이터 필터링
                let thisDayOutMoney = dayFilterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                // 어제 지출 데이터 필터링
                let lastDayOutMoney = lastDayFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                if thisDayOutMoney > lastDayOutMoney {          // 이번주에 더 많이 지출했을 때
                    lastCompareText = "오늘 \(thisDayOutMoney - lastDayOutMoney)원 더 썼어요"
                } else if thisDayOutMoney < lastDayOutMoney {   // 지난주에 더 많이 지출했을 때
                    lastCompareText = "어제 \(lastDayOutMoney - thisDayOutMoney)원 더 썼어요"
                } else {                                            // 이번주와 지난주 지출이 같을 때
                    lastCompareText = "어제 지출과 같아요"
                }
                
                // 막대 그래프
                for value in -6...0 {
                    let barChartDate = calendar.date(byAdding: .day, value: value, to: selectedDate)!
                    let barChartYear = calendar.component(.year, from: barChartDate)
                    let barChartMonth = calendar.component(.month, from: barChartDate)
                    let barChartDay = calendar.component(.day, from: barChartDate)
                    
                    var barChartDayFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        let filterDay = calendar.component(.day, from: $0.purposeDate)
                        
                        return filterYear == barChartYear && filterMonth == barChartMonth && filterDay == barChartDay
                    }
                    
                    // 선택한 날의 시작 시간
                    let startBarChartDay = calendar.startOfDay(for: barChartDate)
                    // 선택한 날의 날 개수
                    let endBarChartDay = calendar.range(of: .day, in: .month, for: barChartDate)?.count
                    
                    // 반복되는 데이터 추출
                    let barChartRepeatDatas = allDbDatas.filter {
                        return $0.purposeDate < startBarChartDay && $0.repeatState == true
                    }
                    
                    for data in barChartRepeatDatas {
                        var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: data.purposeDate)
                        dateComponents.year = barChartYear
                        dateComponents.month = barChartMonth
                        
                        // 선택한 달의 마지막 날보다 높으면 선택한 달의 마지막 날로 할당
                        let filterDay = calendar.component(.day, from: data.purposeDate)
                        
                        if let endDay = endBarChartDay {
                            // 지금이 선택한 달의 마지막 날이고, 선택한 달의 마지막 날보다 높으면 선택한 달의 마지막 날로 할당
                            if filterDay > endDay && barChartDay == endDay {
                                dateComponents.day = endDay
                            } else if filterDay == barChartDay { // 선택한 달의 마지막 날보다 높지 않으면 선택한 날로 할당
                                dateComponents.day = barChartDay
                            } else {
                                continue
                            }
                        }
                        
                        // 반복 데이터의 날짜를 선택한 날짜로 변경 후 barChartDayFliterDatas에 넣어주기
                        if let changedDate = calendar.date(from: dateComponents) {
                            let changedRepeatData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
                            barChartDayFliterDatas.append(changedRepeatData)
                        }
                    }
                    
                    let barChartDayOutMoney = barChartDayFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartDay)일", spendMoney: barChartDayOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = dayFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = Int(data.money)!
                    } else {
                        dic[category]! += Int(data.money)!
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in dayFilterDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
            case 1: // 주별
                print("case 1: 주별")
                let allDbDatas = self.currentState.dbDatas
                
                // 주별 일주일의 시작과 끝 구하기
                let todayWeekday = calendar.component(.weekday, from: selectedDate)
                let startDayInt = (todayWeekday == 1) ? 1 : -(todayWeekday - 1)
                let endDayInt = (todayWeekday == 7) ? 7 : (7 - todayWeekday)
                
                var startWeekDay = calendar.date(byAdding: .day, value: startDayInt, to: selectedDate)!
                startWeekDay = calendar.startOfDay(for: startWeekDay)
                
                var endWeekDay = calendar.date(byAdding: .day, value: endDayInt, to: selectedDate)!
                endWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endWeekDay))!
                
                var weekOfMonthDbDatas = allDbDatas.filter { startWeekDay <= $0.purposeDate && endWeekDay >= $0.purposeDate }
                
                // 1. 반복 데이터 필터링
                let repeatDatas = allDbDatas.filter {
                    $0.purposeDate < startWeekDay &&
                    $0.repeatState == true &&
                    repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startWeekDay, endWeek: endWeekDay, calendar: calendar).map { $0 >= startWeekDay && $0 <= endWeekDay } ?? false
                }
                
                // 2. 매핑된 날짜로 새로운 데이터 생성 후 weekOfMonthDbDatas에 추가
                weekOfMonthDbDatas.append(contentsOf: appendWeekOfRepeatDatas(
                    repeatDatas: repeatDatas,
                    startWeek: startWeekDay,
                    endWeek: endWeekDay,
                    calendar: calendar
                ))
                
                // 날짜
                let weekDateFormatter = DateFormatter()
                weekDateFormatter.dateFormat = "yyyy.MM.dd"
                
                dateText = "\(weekDateFormatter.string(from: startWeekDay)) ~ \(weekDateFormatter.string(from: endWeekDay))"
                
                //총 지출
                outComeMoneyText = String(weekOfMonthDbDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(weekOfMonthDbDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 지난주과 지출 비교
                var startLastWeekDay = calendar.date(byAdding: .day, value: startDayInt + (7 * (-1 + count)), to: today)!
                startLastWeekDay = calendar.startOfDay(for: startLastWeekDay)
                
                var endLastWeekDay = calendar.date(byAdding: .day, value: endDayInt + (7 * (-1 + count)), to: today)!
                endLastWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endLastWeekDay))!
                
                var lastWeekOfMonthFliterDatas = allDbDatas.filter { startLastWeekDay <= $0.purposeDate && endLastWeekDay >= $0.purposeDate }
                
                // 1. 반복 데이터 필터링
                let lastWeekOfRepeatDatas = allDbDatas.filter {
                    $0.purposeDate < startLastWeekDay &&
                    $0.repeatState == true &&
                    repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startLastWeekDay, endWeek: endLastWeekDay, calendar: calendar).map { $0 >= startLastWeekDay && $0 <= endLastWeekDay } ?? false
                }
                
                // 2. 매핑된 날짜로 새로운 데이터 생성 후 lastWeekOfMonthFliterDatas에 추가
                lastWeekOfMonthFliterDatas.append(contentsOf: appendWeekOfRepeatDatas(
                    repeatDatas: lastWeekOfRepeatDatas,
                    startWeek: startLastWeekDay,
                    endWeek: endLastWeekDay,
                    calendar: calendar
                ))
                
                let thisMonthOutMoney = weekOfMonthDbDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                let lastMonthOutMoney = lastWeekOfMonthFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
               
                if thisMonthOutMoney > lastMonthOutMoney {          // 이번주에 더 많이 지출했을 때
                    lastCompareText = "이번주에 \(thisMonthOutMoney - lastMonthOutMoney)원 더 썼어요"
                } else if thisMonthOutMoney < lastMonthOutMoney {   // 지난주에 더 많이 지출했을 때
                    lastCompareText = "지난주에 \(lastMonthOutMoney - thisMonthOutMoney)원 더 썼어요"
                } else {                                            // 이번주와 지난주 지출이 같을 때
                    lastCompareText = "지난주 지출과 같아요"
                }
                
                
                // 막대 그래프(최근 4주 지출)
                for value in -3...0 {
                    var startBarWeekDay = calendar.date(byAdding: .day, value: startDayInt + (value * 7), to: selectedDate)!
                    startBarWeekDay = calendar.startOfDay(for: startBarWeekDay)
                    
                    var endBarWeekDay = calendar.date(byAdding: .day, value: endDayInt + (value * 7), to: selectedDate)!
                    endBarWeekDay = calendar.date(byAdding: .second, value: 86399, to: calendar.startOfDay(for: endBarWeekDay))!
                    
                    var barChartWeekOfMonthFliterDatas = allDbDatas.filter { startBarWeekDay <= $0.purposeDate && endBarWeekDay >= $0.purposeDate }
                    
                    // 1. 반복 데이터 필터링
                    let lastWeekOfBarRepeatDatas = allDbDatas.filter {
                        $0.purposeDate < startBarWeekDay &&
                        $0.repeatState == true &&
                        repeatWeekOfMonthDate(from: $0.purposeDate, startWeek: startBarWeekDay, endWeek: endBarWeekDay, calendar: calendar).map { $0 >= startBarWeekDay && $0 <= endBarWeekDay } ?? false
                    }
                  
                    // 2. 매핑된 날짜로 새로운 데이터 생성 후 barChartWeekOfMonthFliterDatas에 추가
                    barChartWeekOfMonthFliterDatas.append(contentsOf: appendWeekOfRepeatDatas(
                        repeatDatas: lastWeekOfBarRepeatDatas,
                        startWeek: startBarWeekDay,
                        endWeek: endBarWeekDay,
                        calendar: calendar
                    ))
                    
                    let barChartWeekOfMonthOutMoney = barChartWeekOfMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    let barDateFormatter = DateFormatter()
                    barDateFormatter.dateFormat = "MM.dd"
                    
                    barChartDatas.append(BarChartInfo(month: "\(barDateFormatter.string(from: startBarWeekDay)) ~\n\(barDateFormatter.string(from: endBarWeekDay))", spendMoney: barChartWeekOfMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = weekOfMonthDbDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = Int(data.money)!
                    } else {
                        dic[category]! += Int(data.money)!
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in weekOfMonthDbDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
                
            case 2: // 월별
                print("case 2: 월별")
                let allDbDatas = self.currentState.dbDatas
                
                var monthFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == selectedDayYear && filterMonth == selectedDayMonth
                }
                
                let yearMonthFormatter = DateFormatter()
                yearMonthFormatter.dateFormat = "yyyy-MM"
                yearMonthFormatter.locale = Locale(identifier: "ko_KR")
                
                // 매월 반복 데이터 추출
                let repeatDatas: [HomeDataEntity] = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    
                    if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                       let selectedDate = yearMonthFormatter.date(from: "\(selectedDayYear)-\(selectedDayMonth)") {
                        return selectedDate > filterDate && $0.repeatState == true
                    } else {
                        return false
                    }
                }.map { $0 }
                
                monthFilterDatas.append(contentsOf: appendMonthRepeatDatas(year: selectedDayYear, month: selectedDayMonth, repeatDatas: repeatDatas, calendar: calendar))
                
                // 날짜
                dateText = "\(selectedDayYear)년 \(selectedDayMonth)월"
                
                //총 지출
                outComeMoneyText = String(monthFilterDatas
                    .filter { $0.transactionType == "지출" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                
                // 총 수입
                inComeMoneyText = String(monthFilterDatas
                    .filter { $0.transactionType == "수입" }
                    .reduce(0) { $0 + (Int($1.money) ?? 0) })
                // MARK: FIXXING
                // 지난달과 지출 비교
                let lastDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
                let lastYear = calendar.component(.year, from: lastDate)
                let lastMonth = calendar.component(.month, from: lastDate)
                
                var lastMonthFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    
                    return filterYear == lastYear && filterMonth == lastMonth
                }
                
                // 매월 반복 데이터 추출
                let lastRepeatDatas: [HomeDataEntity] = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    
                    if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                       let selectedDate = yearMonthFormatter.date(from: "\(lastYear)-\(lastMonth)") {
                        return selectedDate > filterDate && $0.repeatState == true
                    } else {
                        return false
                    }
                }.map { $0 }
                
                lastMonthFliterDatas.append(contentsOf: appendMonthRepeatDatas(year: lastYear, month: lastMonth, repeatDatas: lastRepeatDatas, calendar: calendar))
                
                let thisMonthOutMoney = monthFilterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                let lastMonthOutMoney = lastMonthFliterDatas
                    .filter {$0.transactionType == "지출"}
                    .reduce(0) { $0 + (Int($1.money) ?? 0) }
                
                if thisMonthOutMoney > lastMonthOutMoney {          // 이번달에 더 많이 지출했을 때
                    lastCompareText = "이번달에 \(thisMonthOutMoney - lastMonthOutMoney)원 더 썼어요"
                } else if thisMonthOutMoney < lastMonthOutMoney {   // 지난달에 더 많이 지출했을 때
                    lastCompareText = "지난달에 \(lastMonthOutMoney - thisMonthOutMoney)원 더 썼어요"
                } else {                                            // 이번달과 지난달 지출이 같을 때
                    lastCompareText = "지난달 지출과 같아요"
                }
                
                // 막대 그래프(최근 6개월 지출)
                for value in -5...0 {
                    let barChartDate = calendar.date(byAdding: .month, value: value, to: selectedDate)!
                    let barChartYear = calendar.component(.year, from: barChartDate)
                    let barChartMonth = calendar.component(.month, from: barChartDate)
                    
                    var barChartMonthFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        return filterYear == barChartYear && filterMonth == barChartMonth
                    }
                    
                    // 매월 반복 데이터 추출
                    let repeatBarDatas: [HomeDataEntity] = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        
                        if let filterDate = yearMonthFormatter.date(from: "\(filterYear)-\(filterMonth)"),
                           let selectedDate = yearMonthFormatter.date(from: "\(barChartYear)-\(barChartMonth)") {
                            return selectedDate > filterDate && $0.repeatState == true
                        } else {
                            return false
                        }
                    }.map { $0 }
                    
                    barChartMonthFliterDatas.append(contentsOf: appendMonthRepeatDatas(year: barChartYear, month: barChartMonth, repeatDatas: repeatBarDatas, calendar: calendar))
                    
                    let barChartMonthOutMoney = barChartMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartMonth)월", spendMoney: barChartMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = monthFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
                    if dic[category] == nil {
                        dic[category] = Int(data.money)!
                    } else {
                        dic[category]! += Int(data.money)!
                    }
                }
                
                for data in dic.sorted(by: {$0.value > $1.value}) {
                    pieChartDatas.append(PieChartInfo(category: data.key, amount: data.value))
                }
                
                // 지출/수입 목록
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d일 EEEE"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                
                for data in monthFilterDatas {
                    let purposeDate = dateFormatter.string(from: data.purposeDate)
                    let emoji = data.transactionType == "수입"
                    ? InComeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    : ExposeCategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(id: data._id.stringValue, transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
            default:
                break
            }
            
            return Observable.concat([
                .just(.updateDisplayDatasMutation(dateText, outComeMoneyText, inComeMoneyText, lastCompareText, barChartDatas, pieChartDatas, inOutDatas)),
                .just(.updateSelectedDateCountMutation(count))
            ])
        }
    }
}

extension StatisticReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchDbDataMutation(let dbDatas):
            newState.dbDatas = dbDatas
            
        case .updateSegmentIndexMutation(let selectedIndex):
            newState.selectedIndex = selectedIndex
            
        case .segmentControlIndexResetMutation:
            newState.selectedIndex = 2
            
        case .updateDisplayDatasMutation(let dateText, let outComeMoneyText, let inComeMoneyText, let lastSixMonthText, let barChartDatas, let pieChartDatas, let inOutDatas):
            
            newState.dateText = dateText
            newState.outComeMoneyText = outComeMoneyText
            newState.inComeMoneyText = inComeMoneyText
            newState.lastSixMonthText = lastSixMonthText
            newState.barChartDatas = barChartDatas
            newState.pieChartDatas = pieChartDatas
            newState.inOutDatas = inOutDatas
        
        case .selectedDateCountResetMutation:
            newState.selectedDateCount = 0
        
        case .updateSelectedDateCountMutation(let count):
            newState.selectedDateCount = count
        }
        
        return newState
    }
}

// MARK: - 주별 관련 함수
// 주 별, 반복 데이터를 현재 주간 날짜 범위에 맞게 계산하는 함수
private func repeatWeekOfMonthDate(from originalDate: Date, startWeek: Date, endWeek: Date, calendar: Calendar) -> Date? {
    let startMonth = calendar.component(.month, from: startWeek)
    let endMonth = calendar.component(.month, from: endWeek)

    let originalComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: originalDate)
    var mappedComponents = originalComponents

    let isSameMonth = startMonth == endMonth
    
    // 시작 날짜와 끝나는 날짜의 달이 같을 때
    if isSameMonth {
        mappedComponents.year = calendar.component(.year, from: startWeek)
        mappedComponents.month = startMonth

        if let day = originalComponents.day,
           let dayCount = calendar.range(of: .day, in: .month, for: originalDate)?.count,
           day == dayCount {
            // 말일이면 주간 시작 날짜 기준으로 말일 보정
            mappedComponents.day = calendar.range(of: .day, in: .month, for: startWeek)?.count
        }
    } else {
        // 한 주가 두 달에 걸친 경우
        guard let day = originalComponents.day,
              let dayCount = calendar.range(of: .day, in: .month, for: originalDate)?.count else {
            return nil
        }

        if day >= 10 {
            mappedComponents.year = calendar.component(.year, from: startWeek)
            mappedComponents.month = startMonth
            // 말일이면 주간 시작 날짜 기준으로 말일 보정
            if day == dayCount {
                mappedComponents.day = calendar.range(of: .day, in: .month, for: startWeek)?.count
            }
        } else {
            mappedComponents.year = calendar.component(.year, from: endWeek)
            mappedComponents.month = endMonth
        }
    }

    return calendar.date(from: mappedComponents)
}

// 매핑된 날짜로 새로운 데이터 생성 후 추가
private func appendWeekOfRepeatDatas(repeatDatas: [HomeDataEntity], startWeek: Date, endWeek: Date, calendar: Calendar,) -> [HomeDataEntity] {
    
    var adjustedDatas: [HomeDataEntity] = []
    
    for data in repeatDatas {
        if let adjustedDate = repeatWeekOfMonthDate(from: data.purposeDate, startWeek: startWeek, endWeek: endWeek, calendar: calendar) {
            let adjustedData = HomeDataEntity(
                _id: data._id,
                transactionType: data.transactionType,
                money: data.money,
                purposeText: data.purposeText,
                purposeDate: adjustedDate,
                repeatState: data.repeatState,
                expenseKind: data.expenseKind,
                selectedCategoryIndex: data.selectedCategoryIndex,
                memoText: data.memoText
            )
            
            adjustedDatas.append(adjustedData)
        }
    }
    
    return adjustedDatas
}

// MARK: - 월별
// 매핑된 날짜로 새로운 데이터 생성 후 추가
private func appendMonthRepeatDatas(year: Int, month: Int, repeatDatas: [HomeDataEntity], calendar: Calendar) -> [HomeDataEntity] {
    let yearMonthFormatter = DateFormatter()
    yearMonthFormatter.dateFormat = "yyyy-MM"
    yearMonthFormatter.locale = Locale(identifier: "ko_KR")
    
    var adjustedDatas: [HomeDataEntity] = []
    
    if let repeatDate = yearMonthFormatter.date(from: "\(year)-\(month)") {
        for data in repeatDatas {
            // 반복되는 일(day)값을 이용하여 선택한 달의 해당하는 날 구하기
            let fromComponents = calendar.dateComponents([.year, .month], from: repeatDate)
            let toComponents = calendar.dateComponents([.year, .month], from: data.purposeDate)
            
            var changedPurposeDate = data.purposeDate
            
            if let fromYear = fromComponents.year,
               let fromMonth = fromComponents.month,
               let toYear = toComponents.year,
               let toMonth = toComponents.month {

                let fromTotalMonths = fromYear * 12 + fromMonth
                let toTotalMonths = toYear * 12 + toMonth
                // 월 차이 구하기
                let monthDiff = fromTotalMonths - toTotalMonths
                // 선택한 달의 날로 날짜 변경
                changedPurposeDate = calendar.date(byAdding: .month, value: monthDiff, to: data.purposeDate) ?? data.purposeDate
            }
            
            let changedData = HomeDataEntity(_id: data._id, transactionType: data.transactionType, money: data.money, purposeText: data.purposeText, purposeDate: changedPurposeDate, repeatState: data.repeatState, expenseKind: data.expenseKind, selectedCategoryIndex: data.selectedCategoryIndex, memoText: data.memoText)
            
            adjustedDatas.append(changedData)
        }
    }
    
    return adjustedDatas
}
