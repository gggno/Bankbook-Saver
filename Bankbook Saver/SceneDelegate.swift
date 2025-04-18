//
//  SceneDelegate.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/23/24.
//

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let realm = try! Realm()
        // 내부 디비에 저장된 화면모드 데이터 가져오기
        let myPageDisplayMode = realm.objects(MyPageDisplayModeEntity.self).first ?? MyPageDisplayModeEntity()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 화면모드 적용
        switch myPageDisplayMode.displayMode {
        case DisplayType.dark.rawValue:
            window?.overrideUserInterfaceStyle = .dark
            
        case DisplayType.light.rawValue:
            window?.overrideUserInterfaceStyle = .light
            
        case DisplayType.system.rawValue:
            window?.overrideUserInterfaceStyle = .unspecified
            
        default:
            window?.overrideUserInterfaceStyle = .unspecified
        }
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .label
        
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
        let mypageViewController = UINavigationController(rootViewController: MypageViewController())
        
        homeViewController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        statisticViewController.tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar.xaxis"), tag: 1)
        mypageViewController.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.fill"), tag: 2)
        
        tabBarController.viewControllers = [homeViewController, statisticViewController, mypageViewController]
        
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

