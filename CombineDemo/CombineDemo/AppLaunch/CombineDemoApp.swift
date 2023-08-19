//
//  CombineDemoApp.swift
//  CombineDemo
//
//  Created by Manish Rathi on 27/03/2023.
//

/*
import SwiftUI

@main
struct CombineDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window

        let viewController = PokemonListViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        self.window?.rootViewController = navigationController

        return true
    }
}
