import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var commands: Commands = {
        let commands: Commands = Commands()
        return commands;
    }()
    
    lazy var backendEvents: BackendEvents = {
        let backendEvents: BackendEvents = BackendEvents()
        return backendEvents
    }()
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard #available(iOS 13.0, *) else {
            GeneratedPluginRegistrant.register(with: self)
            
            let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
            
            // exchange to navigation view controller
            let naviViewController: UINavigationController = UINavigationController(rootViewController: flutterViewController)
            naviViewController.isNavigationBarHidden = true
            window?.rootViewController = naviViewController

            // regist method channel
            commands.register(delegate: self, withBinaryMessager: flutterViewController.binaryMessenger)
            backendEvents.register(withBinaryMessager: flutterViewController.binaryMessenger)
            
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        commands.shareFromExtension(url)
        return true
    }
}

extension AppDelegate : CommandDelegate {
    func getNavigationController() -> UINavigationController {
        return window?.rootViewController as! UINavigationController
    }
}
