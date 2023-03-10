//
//  SceneDelegate.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/15/22.
//

import UIKit
import Foundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
 

   // deinit {
   //     UserDefaults.standard.removeObserver(self, forKeyPath: "theme", context: nil)
   // }
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        var controller: UIViewController!
        UserDefaults.standard.addObserver(self, forKeyPath: "theme", options: [.new], context: nil)
        UserDefaults.standard.setValue(Theme.light.rawValue, forKey: "theme")
        
        if UserDefaults.standard.string(forKey: "theme") == "light"{
            self.window?.overrideUserInterfaceStyle = .light

        }
        else{
            self.window?.overrideUserInterfaceStyle = .dark

        }
            

        if UserDefaults.standard.hasOnboarded {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            controller = storyboard.instantiateViewController(identifier: "Map") as! UINavigationController
        } else {
            controller = OnboardingViewController.instantiate()
        }
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
     

    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        print("Changing")
        guard
            let change = change,
            object != nil,
            let themeValue = change[.newKey] as? String,
            let theme = Theme(rawValue: themeValue)?.uiInterfaceStyle
        else {
            print("returned")
            return
            
        }

        let rawValue = UserDefaults.standard.integer(forKey: "theme")

        print("Theme = " + String(rawValue))
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [weak self] in
            self?.window?.overrideUserInterfaceStyle = theme
        }, completion: .none)
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
