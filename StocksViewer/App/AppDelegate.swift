//
//  AppDelegate.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Clear UserDefaults if UITests are running
        let args = ProcessInfo.processInfo.arguments
        if args.contains("UITestMode") {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        
        // Use mocked session if UITests are running
        // Or default, if not
        let session: URLSessionProtocol = ProcessInfo.processInfo.decode(URLSessionMock.self) ?? URLSession(configuration: .default)
        NetworkManager.shared.session = session
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

