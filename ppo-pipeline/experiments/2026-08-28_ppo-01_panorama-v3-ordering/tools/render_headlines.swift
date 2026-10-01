// Renders the verb-split headline of each print in any locale on top of the
// text-free base prints, for one display type. CoreText does bidi + shaping +
// font fallback, so Arabic / Hebrew / Devanagari / Thai / CJK come out right.
// Layout is defined for 1320x2868 and scaled by height for the other sizes.
//
// usage: swift render_headlines.swift <base_dir> <headlines.json> <out_dir> <W> <H> [locale ...]
import Foundation
import AppKit
import CoreText

let args = CommandLine.arguments
guard args.count >= 6 else { fputs("usage: render_headlines.swift <base_dir> <headlines.json> <out_dir> <W> <H> [locale...]\n", stderr); exit(1) }
let baseDir = args[1], jsonPath = args[2], outDir = args[3]
let W = Int(args[4])!, H = Int(args[5])!
let only = Array(args.dropFirst(6))

let k = CGFloat(H) / 2868.0                 // reference layout is 6.9"
let centerX = CGFloat(W) / 2
let baseline1: CGFloat = 288 * k
let baseline2: CGFloat = 394 * k
let maxWidth: CGFloat = CGFloat(W) * 0.88
let shadowBlur: CGFloat = 14 * k

let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: jsonPath))) as! [String: Any]
let defaults = json["_default"] as! [String: Any]

func loadImage(_ path: String) -> CGImage {
    let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(src, 0, nil)!
}

func save(_ img: CGImage, _ path: String) {
    let dst = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(dst, img, nil)
    CGImageDestinationFinalize(dst)
}

func makeLine(_ text: String, size: CGFloat) -> (CTLine, CGFloat) {
    let font = NSFont.systemFont(ofSize: size, weight: .black)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    return (line, width)
}

func draw(_ ctx: CGContext, _ text: String, size: CGFloat, baselineFromTop: CGFloat) {
    var (line, width) = makeLine(text, size: size)
    if width > maxWidth { (line, width) = makeLine(text, size: size * maxWidth / width) }
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -4 * k), blur: shadowBlur, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    ctx.textPosition = CGPoint(x: centerX - width / 2, y: CGFloat(H) - baselineFromTop)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

let fm = FileManager.default
for (locale, value) in json where !locale.hasPrefix("_") && locale != "screens" {
    if !only.isEmpty && !only.contains(locale) { continue }
    let cfg = value as! [String: Any]
    let panels = cfg["panels"] as! [[String]]
    let size1 = CGFloat((cfg["size1"] ?? defaults["size1"]) as! Double) * k
    let size2 = CGFloat((cfg["size2"] ?? defaults["size2"]) as! Double) * k
    let dir = "\(outDir)/\(locale)"
    try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
    for (i, pair) in panels.enumerated() {
        let base = loadImage("\(baseDir)/0\(i + 1).png")
        let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        ctx.draw(base, in: CGRect(x: 0, y: 0, width: W, height: H))
        ctx.setAllowsFontSmoothing(true); ctx.setShouldSmoothFonts(true)
        draw(ctx, pair[0], size: size1, baselineFromTop: baseline1)
        draw(ctx, pair[1], size: size2, baselineFromTop: baseline2)
        save(ctx.makeImage()!, "\(dir)/0\(i + 1).png")
    }
    print("rendered \(locale) \(W)x\(H)")
}
