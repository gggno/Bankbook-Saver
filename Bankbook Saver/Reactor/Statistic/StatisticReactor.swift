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
            let todayWeekOfMonth = calendar.component(.weekOfMonth, from: today)
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

                let dayFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == todayYear && filterMonth == todayMonth && filterDay == todayDay
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
                
                let lastDayFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == lastYear && filterMonth == lastMonth && filterDay == lastDay
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
                    
                    let barChartDayFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        let filterDay = calendar.component(.day, from: $0.purposeDate)
                        
                        return filterYear == barChartYear && filterMonth == barChartMonth && filterDay == barChartDay
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
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
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
                
                let weekOfMonthDbDatas = allDbDatas.filter { startWeekDay <= $0.purposeDate && endWeekDay >= $0.purposeDate }
                
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
                
                let lastWeekOfMonthFliterDatas = allDbDatas.filter { startLastWeekDay <= $0.purposeDate && endLastWeekDay >= $0.purposeDate }
                                
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
                    
                    let barChartWeekOfMonthFliterDatas = allDbDatas.filter { startBarWeekDay <= $0.purposeDate && endBarWeekDay >= $0.purposeDate }
                    
                    let barChartWeekOfMonthOutMoney = barChartWeekOfMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    let barDateFormatter = DateFormatter()
                    barDateFormatter.dateFormat = "MM.dd"
                    
                    barChartDatas.append(BarChartInfo(month: "\(barDateFormatter.string(from: startBarWeekDay)) ~ \(barDateFormatter.string(from: endBarWeekDay))", spendMoney: barChartWeekOfMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = weekOfMonthDbDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
                
            case 2: // 월별
                print("case 2: 월별")
                let allDbDatas = self.currentState.dbDatas
                
                let monthFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == todayYear && filterMonth == todayMonth
                }
                
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
                let lastMonthFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == lastYear && filterMonth == lastMonth
                }
                
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
                    let barChartDate = calendar.date(byAdding: .month, value: value, to: today)!
                    let barChartYear = calendar.component(.year, from: barChartDate)
                    let barChartMonth = calendar.component(.month, from: barChartDate)
                    
                    let barChartMonthFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        return filterYear == barChartYear && filterMonth == barChartMonth
                    }
                    
                    let barChartMonthOutMoney = barChartMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartMonth)월", spendMoney: barChartMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = monthFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
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
            
            // today라는 이름 안됨. 변경해야 함
            let todayYear = calendar.component(.year, from: selectedDate)
            let todayMonth = calendar.component(.month, from: selectedDate)
            let todayWeekOfMonth = calendar.component(.weekOfMonth, from: selectedDate)
            let todayDay = calendar.component(.day, from: selectedDate)
            print("selectedDate: \(selectedDate)")
            print("todayWeekOfMonth: \(todayWeekOfMonth)")
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

                let dayFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == todayYear && filterMonth == todayMonth && filterDay == todayDay
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
                
                let lastDayFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    let filterDay = calendar.component(.day, from: $0.purposeDate)
                    
                    return filterYear == lastYear && filterMonth == lastMonth && filterDay == lastDay
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
                    
                    let barChartDayFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        let filterDay = calendar.component(.day, from: $0.purposeDate)
                        
                        return filterYear == barChartYear && filterMonth == barChartMonth && filterDay == barChartDay
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
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
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
                
                let weekOfMonthDbDatas = allDbDatas.filter { startWeekDay <= $0.purposeDate && endWeekDay >= $0.purposeDate }
                
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
                
                let lastWeekOfMonthFliterDatas = allDbDatas.filter { startLastWeekDay <= $0.purposeDate && endLastWeekDay >= $0.purposeDate }
                                
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
                    
                    let barChartWeekOfMonthFliterDatas = allDbDatas.filter { startBarWeekDay <= $0.purposeDate && endBarWeekDay >= $0.purposeDate }
                    
                    let barChartWeekOfMonthOutMoney = barChartWeekOfMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    let barDateFormatter = DateFormatter()
                    barDateFormatter.dateFormat = "MM.dd"
                    
                    barChartDatas.append(BarChartInfo(month: "\(barDateFormatter.string(from: startBarWeekDay)) ~ \(barDateFormatter.string(from: endBarWeekDay))", spendMoney: barChartWeekOfMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = weekOfMonthDbDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    }
                }
                
                
            case 2: // 월별
                print("case 2: 월별")
                let allDbDatas = self.currentState.dbDatas
                
                let monthFilterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == todayYear && filterMonth == todayMonth
                }
                
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
                let lastMonthFliterDatas = allDbDatas.filter {
                    let filterYear = calendar.component(.year, from: $0.purposeDate)
                    let filterMonth = calendar.component(.month, from: $0.purposeDate)
                    return filterYear == lastYear && filterMonth == lastMonth
                }
                
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
                    
                    let barChartMonthFliterDatas = allDbDatas.filter {
                        let filterYear = calendar.component(.year, from: $0.purposeDate)
                        let filterMonth = calendar.component(.month, from: $0.purposeDate)
                        return filterYear == barChartYear && filterMonth == barChartMonth
                    }
                    
                    let barChartMonthOutMoney = barChartMonthFliterDatas
                        .filter {$0.transactionType == "지출"}
                        .reduce(0) { $0 + (Int($1.money) ?? 0) }
                    
                    barChartDatas.append(BarChartInfo(month: "\(barChartMonth)월", spendMoney: barChartMonthOutMoney))
                }
                
                // 원 그래프(카테고리 별 지출)
                let outComeDatas = monthFilterDatas.filter{$0.transactionType == "지출"}
                
                var dic: [String: Int] = [:]
                for data in outComeDatas {
                    let category = CategoryType(rawValue: data.selectedCategoryIndex)?.title ?? ""
                    
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
                    let emoji = CategoryType(rawValue: data.selectedCategoryIndex)?.emoji ?? ""
                    let money = data.transactionType == "수입" ? data.money : String(-Int(data.money)!)
                    let detailUse = data.purposeText
                    
                    
                    if inOutDatas[purposeDate] == nil {
                        inOutDatas[purposeDate] = [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
                    } else {
                        inOutDatas[purposeDate]! += [InOutCellInfo(transactionType: data.transactionType, emoji: emoji, money: money, detailUse: detailUse)]
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
