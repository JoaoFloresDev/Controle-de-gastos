import AppKit
import CoreGraphics
import Foundation

// Composes one 2880x1800 Mac App Store screenshot in the GambitStudio look:
// flat brand background, verb-split headline (first word big, rest smaller),
// and the real app window with rounded corners and a shadow. Optional breakout:
// a crop of the window, scaled up, glowing in the brand colour, overflowing the
// window edge.
//
//   swift render_print.swift --window shot.png --out 01.png \
//        --first CONTROLE --rest "SEUS GASTOS NO MAC" [--breakout x,y,w,h]

struct Args {
    var window = "", out = "", first = "", rest = ""
    var bg = "#0B3FA0", glow = "#3E8BFF", language = "pt-BR"
    var breakout: CGRect? = nil
    var breakoutScale: CGFloat = 1.15
    var breakoutSide = "right"
}

func parseArgs() -> Args {
    var a = Args()
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let key = it.next() {
        guard let value = it.next() else { break }
        switch key {
        case "--window": a.window = value
        case "--out": a.out = value
        case "--first": a.first = value
        case "--rest": a.rest = value
        case "--bg": a.bg = value
        case "--glow": a.glow = value
        case "--language": a.language = value
        case "--breakout":
            let p = value.split(separator: ",").compactMap { Double($0) }
            if p.count == 4 { a.breakout = CGRect(x: p[0], y: p[1], width: p[2], height: p[3]) }
        case "--breakout-scale": a.breakoutScale = CGFloat(Double(value) ?? 1.15)
        case "--breakout-side": a.breakoutSide = value
        default: break
        }
    }
    return a
}

func color(_ hex: String, alpha: CGFloat = 1) -> CGColor {
    var s = hex
    if s.hasPrefix("#") { s.removeFirst() }
    let v = UInt32(s, radix: 16) ?? 0
    return CGColor(red: CGFloat((v >> 16) & 0xFF) / 255.0,
                   green: CGFloat((v >> 8) & 0xFF) / 255.0,
                   blue: CGFloat(v & 0xFF) / 255.0, alpha: alpha)
}

func loadImage(_ path: String) -> CGImage? {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)
    else { return nil }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
}

/// Draws one centred line, shrinking the size until it fits — pt-BR headlines
/// run noticeably longer than the en-US ones.
func drawLine(_ ctx: CGContext, _ text: String, size: CGFloat, weight: NSFont.Weight,
              centerX: CGFloat, baselineY: CGFloat, language: String, maxWidth: CGFloat) {
    guard !text.isEmpty else { return }
    var fontSize = size
    var line: CTLine?
    var width: CGFloat = 0
    while fontSize > 24 {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: weight),
            .foregroundColor: NSColor.white,
            .kern: -fontSize * 0.02,
            NSAttributedString.Key(kCTLanguageAttributeName as String): language,
        ]
        let l = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: attrs))
        width = CGFloat(CTLineGetTypographicBounds(l, nil, nil, nil))
        if width <= maxWidth { line = l; break }
        fontSize -= 4
    }
    guard let l = line else { return }
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 22,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.35))
    ctx.textPosition = CGPoint(x: centerX - width / 2, y: baselineY)
    CTLineDraw(l, ctx)
    ctx.restoreGState()
}

func rounded(_ rect: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

let args = parseArgs()
guard let shot = loadImage(args.window) else {
    FileHandle.standardError.write("cannot read \(args.window)\n".data(using: .utf8)!)
    exit(1)
}

let W: CGFloat = 2880, H: CGFloat = 1800
guard let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8,
                          bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { exit(1) }

ctx.setFillColor(color(args.bg))
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

// CoreGraphics origin is bottom-left, so baselines count down from the top.
drawLine(ctx, args.first.uppercased(), size: 176, weight: .black,
         centerX: W / 2, baselineY: H - 250, language: args.language, maxWidth: W - 300)
drawLine(ctx, args.rest.uppercased(), size: 92, weight: .heavy,
         centerX: W / 2, baselineY: H - 378, language: args.language, maxWidth: W - 320)

// A janela do Mac é 16:10 e larga; 1920 é o maior tamanho que ainda deixa a
// headline respirar em cima e uma margem embaixo.
let winW: CGFloat = 1920
let winH = winW * CGFloat(shot.height) / CGFloat(shot.width)
let winRect = CGRect(x: (W - winW) / 2, y: 150, width: winW, height: winH)
let radius: CGFloat = 34

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -26), blur: 60,
              color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.55))
ctx.setFillColor(CGColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1))
ctx.addPath(rounded(winRect, radius))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(rounded(winRect, radius))
ctx.clip()
ctx.draw(shot, in: winRect)
ctx.restoreGState()

// Hairline so the dark window separates from the dark-blue ground.
ctx.saveGState()
ctx.addPath(rounded(winRect, radius))
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.14))
ctx.setLineWidth(3)
ctx.strokePath()
ctx.restoreGState()

if let crop = args.breakout, let piece = shot.cropping(to: crop) {
    let scale = winW / CGFloat(shot.width) * args.breakoutScale
    let bw = CGFloat(piece.width) * scale
    let bh = CGFloat(piece.height) * scale
    // Quando o recorte fica MAIS LARGO que a janela ele transborda as duas
    // bordas — é o transbordo que cria o efeito de pop-out (padrão da casa).
    let x = bw >= winW
        ? (W - bw) / 2
        : (args.breakoutSide == "left" ? winRect.minX - 120 : winRect.maxX + 120 - bw)
    let bRect = CGRect(x: x, y: winRect.minY - 78, width: bw, height: bh)

    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 70, color: color(args.glow, alpha: 0.85))
    ctx.setFillColor(CGColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1))
    ctx.addPath(rounded(bRect, 26))
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(rounded(bRect, 26))
    ctx.clip()
    ctx.draw(piece, in: bRect)
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(rounded(bRect, 26))
    ctx.setStrokeColor(color(args.glow))
    ctx.setLineWidth(5)
    ctx.strokePath()
    ctx.restoreGState()
}

guard let image = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args.out) as CFURL,
                                                 "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("wrote \(args.out)")
