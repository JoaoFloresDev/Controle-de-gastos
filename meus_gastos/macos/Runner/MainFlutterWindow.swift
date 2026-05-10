import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Open maximized to fill the available screen area (visible frame
    // excludes the menu bar and Dock). User can still resize/zoom out.
    if let screenFrame = NSScreen.main?.visibleFrame {
      self.setFrame(screenFrame, display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
