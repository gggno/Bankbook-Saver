//
//  LocalNotiManager.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/5/25.
//

import Foundation
import UserNotifications

class LocalNotiManager {
    static let shared = LocalNotiManager()
    
    // 알람 권한 부여
    func permissionAuthorization(completion: @escaping (Bool) -> Void) {
        print("LocalNotiManager - permissionAuthorization()")
        let authorizationOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions,
                                                                completionHandler: { state, error in
            completion(state)
            
            if let error = error {
                print("permissionAuthorization() - ERROR: " + error.localizedDescription)
            }
        })
    }
    
    // 매일 가게부 작성 알람 등록
    func setDailyReminder() {
        print("LocalNotiManager - setDailyReminder()")
        
        let identifier = "DailyReminder"
        
        // 1. 알림 내용 작성
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "오늘 하루의 소비 내역을 작성해보세요! 😁"
        notificationContent.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21  // 9시
        dateComponents.minute = 0  // 0분
        
        // 2. 알림 시간 작성(시간, 반복)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 3. 요청
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        
        // 4. 알림 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("setDailyReminder - Notification Error: ", error)
            }
        }
    }
    
    // 매일 가게부 작성 알람 해제
    func cancelDailyReminder() {
        print("LocalNotiManager - cancelDailyReminder()")
        
        let identifier = "DailyReminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // 매일 가게부 존재 여부
    func dailyReminderExists(completion: @escaping (Bool) -> Void) {
        print("LocalNotiManager - dailyReminderExists()")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests.contains { $0.identifier == "DailyReminder" })
        }
    }
    
    // 매월 정기 구독 결제일 알림 등록
    func setRepeatPayment(id: String, purposeText: String, purposeDate: Date) {
        print("LocalNotiManager - setRepeatPayment()")
        
        let identifier = "RepeatPayment_\(id)"
        
        // 1. 알림 내용 작성
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "내일은 \(purposeText) 결제 예정일 입니다."
        notificationContent.sound = .default
        
        
        // 2. 알림 시간 작성(시간, 반복)
        // 하루 전 날짜 계산
        let calendar = Calendar.current
        guard let dayBeforePurposeDate = calendar.date(byAdding: .day, value: -1, to: purposeDate) else {
            return
        }
        
        // 어제 day값 추출
        let yesterday = calendar.dateComponents([.day], from: dayBeforePurposeDate).day
        
        var dateComponents = DateComponents()
        dateComponents.day = yesterday
        dateComponents.hour = 20  // 8시
        dateComponents.minute = 0  // 0분
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 3. 요청
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        
        // 4. 알림 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("setRepeatPayment - Notification Error: ", error)
            }
        }
    }
    
    // 매월 정기 수입일 알림 등록
    func setRepeatIncome(id: String, purposeText: String, purposeDate: Date) {
        print("LocalNotiManager - setRepeatIncome()")
        
        let identifier = "RepeatIncome_\(id)"
        
        // 1. 알림 내용 작성
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "내일은 \(purposeText)이 들어올 예정입니다."
        notificationContent.sound = .default
        
        
        // 2. 알림 시간 작성(시간, 반복)
        // 하루 전 날짜 계산
        let calendar = Calendar.current
        guard let dayBeforePurposeDate = calendar.date(byAdding: .day, value: -1, to: purposeDate) else {
            return
        }
        
        // 어제 day값 추출
        let yesterday = calendar.dateComponents([.day], from: dayBeforePurposeDate).day
        
        var dateComponents = DateComponents()
        dateComponents.day = yesterday
        dateComponents.hour = 20  // 8시
        dateComponents.minute = 0  // 0분
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 3. 요청
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        
        // 4. 알림 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("setRepeatIncome - Notification Error: ", error)
            }
        }
    }
    
    // 매월 지출 알림 해제
    func cancelRepeatPaymentNoti(id: String) {
        print("LocalNotiManager - cancelRepeatPaymentNoti()")
        
        let identifier = "RepeatPayment_\(id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // 매월 수입 알림 해제
    func cancelRepeatIncomeNoti(id: String) {
        print("LocalNotiManager - cancelRepeatIncomeNoti()")
        
        let identifier = "RepeatIncome_\(id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    
    // 현재 등록된 로컬 알림 확인
    func checkRegisteredLocalNoti() {
        print("LocalNotiManager - checkRegisteredLocalNoti()")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("등록된 로컬 알림: \(requests)")
        }
    }
}
