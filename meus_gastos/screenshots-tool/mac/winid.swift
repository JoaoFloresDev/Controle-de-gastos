import CoreGraphics
import Foundation

// Prints "<windowNumber> <owner> <w> <h> <x> <y>" for every on-screen window.
// The capture script picks the app's window out of it; the app's owner name is
// the LOCALISED name ("Despesas" in pt-BR), so match on several spellings.
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements],
                                      kCGNullWindowID) as? [[String: Any]] ?? []
for w in list {
    let owner = w[kCGWindowOwnerName as String] as? String ?? "?"
    let num = w[kCGWindowNumber as String] as? Int ?? 0
    let b = w[kCGWindowBounds as String] as? [String: Any] ?? [:]
    print(num, owner, b["Width"] ?? "", b["Height"] ?? "", b["X"] ?? "", b["Y"] ?? "")
}
