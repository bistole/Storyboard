import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var commands: Commands = {
        let commands: Commands = Commands()
        return commands;
    }()
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // exchange to navigation view controller
        let naviViewController: UINavigationController = UINavigationController(rootViewController: flutterViewController)
        naviViewController.isNavigationBarHidden = true
        window?.rootViewController = naviViewController

        // regist method channel
        commands.register(delegate: self, withBinaryMessager: flutterViewController.binaryMessenger)
        
    
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
