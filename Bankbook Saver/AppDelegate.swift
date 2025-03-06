//
//  AppDelegate.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/23/24.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        
        LocalNotiManager.shared.permissionAuthorization { state in
            if state {  // 알림 권한이 허용인 상태일 때
                print("알림 권한 허용")
                let realm = try! Realm()
                print("Realm is located at:", realm.configuration.fileURL!) // 저장된 DB 주소 확인
                
                let isFirstLaunch = realm.objects(IsFirstLaunchEntity.self).first ?? nil
                
                if isFirstLaunch == nil {   // 앱을 처음 실행 했을 때
                    print("isFirstLaunch == nil")
                    RealmManager.shared.createIsFirstLaunch()
                    LocalNotiManager.shared.setDailyReminder()  // 매일 알림 허용
                }
                LocalNotiManager.shared.checkRegisteredLocalNoti()
                
            } else {    // 알림 권한이 해제 상태일 때
                print("알림 권한 해제")
                
                LocalNotiManager.shared.checkRegisteredLocalNoti()
            }
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 포그라운드일 때도 알림이 활성화
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}
