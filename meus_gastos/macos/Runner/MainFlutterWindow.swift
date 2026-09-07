import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // MARK: - Constants

  /// Size the window opens at on a fresh install. Wide enough for the sidebar
  /// plus the content column, short enough to leave the desktop visible.
  private static let defaultContentSize = NSSize(width: 1180, height: 820)

  /// Below this the sidebar and the charts start clipping.
  private static let minContentSize = NSSize(width: 940, height: 640)

  /// Frame is remembered between launches under this key.
  private static let frameAutosaveKey = "MyExpensesMainWindow"

  // MARK: - Lifecycle

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    configureChrome()
    applyInitialFrame()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  // MARK: - Window chrome

  /// The Flutter UI is dark; without this the title bar renders light and the
  /// window reads as two apps stitched together.
  private func configureChrome() {
    self.appearance = NSAppearance(named: .darkAqua)
    self.titlebarAppearsTransparent = true
    self.backgroundColor = NSColor(
      red: 0x0D / 255.0, green: 0x11 / 255.0, blue: 0x17 / 255.0, alpha: 1)
    self.isMovableByWindowBackground = true
    self.minSize = Self.minContentSize
  }

  // MARK: - Frame

  /// Restores the frame the user left the app in. Only when there is nothing
  /// stored do we place a centered default window — the old build forced the
  /// full visible frame on every launch, which stretched a phone-shaped layout
  /// across a 27" display and threw away any resize the user made.
  private func applyInitialFrame() {
    let restored = setFrameUsingName(NSWindow.FrameAutosaveName(Self.frameAutosaveKey))
    if !restored {
      let visible = NSScreen.main?.visibleFrame ?? NSRect(origin: .zero, size: Self.defaultContentSize)
      let width = min(Self.defaultContentSize.width, visible.width)
      let height = min(Self.defaultContentSize.height, visible.height)
      let origin = NSPoint(
        x: visible.midX - width / 2,
        y: visible.midY - height / 2)
      setFrame(NSRect(origin: origin, size: NSSize(width: width, height: height)), display: true)
    }
    self.setFrameAutosaveName(NSWindow.FrameAutosaveName(Self.frameAutosaveKey))
  }
}
