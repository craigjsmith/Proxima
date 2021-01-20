//
//  AppDelegate.swift
//  Proxima
//
//  Created by Craig Smith on 11/18/20.
//

import UIKit
import Parse
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Load keys from plist
        let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: filePath!)
        
        // Parse setup
        let parseConfig = ParseClientConfiguration {
                    $0.applicationId = plist?.object(forKey: "PARSE_APPID") as! String
                    $0.clientKey = plist?.object(forKey: "PARSE_CLIENTKEY") as! String
                    $0.server = plist?.object(forKey: "PARSE_SERVER") as! String
            }
            Parse.initialize(with: parseConfig)
        
        // Setup Parse for authentication with Apple
        PFUser.register(AuthDelegate(), forAuthType: "apple")
            
        // IQ Keyboard Manager setup
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
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

