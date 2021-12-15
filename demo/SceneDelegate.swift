//
//  SceneDelegate.swift
//  demo
//
//  Created by Yoav Pasovsky on 31.08.21.
//

import UIKit
import Trailze

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let mapboxToken = Bundle.main.mapboxAccessToken
        let trailzeToken = Bundle.main.trailzeAccessToken
        let optionsBuilder = OptionsBuilder()
            .addApiToken(trailzeToken)
            .addMapBoxToken(mapboxToken)
            .addUserId(UUID().uuidString)
            .setBaseRouteColor(UIColor(red: 0.35, green: 0.67, blue: 0.96, alpha: 1.00))
            .setSafeRouteColor(UIColor(red: 0.47, green: 0.76, blue: 0.29, alpha: 1.00))
            .setDangerousRouteColor(UIColor(red: 0.91, green: 0.20, blue: 0.28, alpha: 1.00))
                        
        let options = optionsBuilder.build()
        TrailzeApp.configure(with: options)

        
        let viewController = MainViewController()
                
        self.setViewControllerForWindow(window, viewController)
    }
    
    func setViewControllerForWindow(_ window: UIWindow, _ viewController: UIViewController) {
        let navigation = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigation
        navigation.setViewControllers([viewController], animated: false)
        self.window = window
        window.makeKeyAndVisible()
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

