//
//  SceneDelegate.swift
//  Runner
//
//  Created by Simon Ding on 2021-05-17.
//

import Foundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    lazy var commands: Commands = {
        let commands: Commands = Commands()
        return commands;
    }()
    
    lazy var backendEvents: BackendEvents = {
        let backendEvents: BackendEvents = BackendEvents()
        return backendEvents
    }()
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        let flutterEngine = FlutterEngine(name: "SceneDelegateEngine")
        flutterEngine.run()
        
        let flutterViewController = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        let naviViewController: UINavigationController = UINavigationController(rootViewController: flutterViewController)
        naviViewController.isNavigationBarHidden = true
        
        window?.rootViewController = naviViewController
        window?.makeKeyAndVisible()
        
        // regist method channel
        GeneratedPluginRegistrant.register(with: flutterEngine)
        commands.register(delegate: self, withBinaryMessager: flutterViewController.binaryMessenger)
        backendEvents.register(withBinaryMessager: flutterViewController.binaryMessenger)
        
        // handle is url existed
        if let url = connectionOptions.urlContexts.first?.url {
            commands.shareFromExtension(url)
        }
    }
        
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            commands.shareFromExtension(url)
        }
    }
}

extension SceneDelegate : CommandDelegate {
    func getNavigationController() -> UINavigationController {
        return window?.rootViewController as! UINavigationController
    }
}
