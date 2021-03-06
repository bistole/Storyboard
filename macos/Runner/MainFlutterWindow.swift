import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    @IBOutlet weak var backendEvents: BackendEvents!
    @IBOutlet weak var menuEvent: MenuEvents!
    @IBOutlet weak var commands: Commands!

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        RegisterGeneratedPlugins(registry: flutterViewController)

        backendEvents.register(withBinaryMessager: flutterViewController.engine.binaryMessenger);
        menuEvent.register(withBinaryMessager: flutterViewController.engine.binaryMessenger);
        commands.register(withBinaryMessager: flutterViewController.engine.binaryMessenger);

        super.awakeFromNib();
    }
}
