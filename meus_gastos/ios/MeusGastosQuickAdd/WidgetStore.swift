//
//  WidgetStore.swift
//  MeusGastosQuickAdd
//
//  Shared App Group storage between the Flutter app and the Quick Add widget.
//

import Foundation
import SwiftUI

// MARK: - Category model
struct WidgetCategory: Identifiable {
    let id: String
    let name: String
    let color: Color
    /// Material Icons codepoint synced from the app, so the widget draws the
    /// exact same glyph the "add expense" screen shows (custom categories too).
    let iconCodePoint: Int?
    /// SF Symbol fallback, used only when the app hasn't synced a codepoint yet.
    let symbol: String

    var glyph: String? {
        guard let cp = iconCodePoint, let scalar = UnicodeScalar(cp) else { return nil }
        return String(Character(scalar))
    }
}

// MARK: - Store
enum WidgetStore {
    // MARK: Constants
    static let appGroup = "group.com.gambit.meusgastos"

    static let kCategories = "widget_categories"
    static let kCurrency = "widget_currency"
    static let kPending = "widget_pending_expenses"
    static let kPendingAmount = "widget_pending_amount"
    static let kUndoDeadline = "widget_undo_deadline" // ms epoch
    static let kUndoAmount = "widget_undo_amount"

    /// Janela em que o botão "desfazer" fica disponível após adicionar.
    static let undoWindow: TimeInterval = 5

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }

    // MARK: Running total (value buttons sum into this)
    static func pendingAmount() -> Double {
        defaults?.double(forKey: kPendingAmount) ?? 0
    }

    static func addToPending(_ amount: Double) {
        defaults?.set(pendingAmount() + amount, forKey: kPendingAmount)
    }

    static func clearPending() {
        defaults?.set(0.0, forKey: kPendingAmount)
    }

    // MARK: Currency
    static func currencySymbol() -> String {
        let raw = defaults?.string(forKey: kCurrency) ?? "$"
        return raw.isEmpty ? "$" : raw
    }

    static func formatted(_ amount: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        let value = nf.string(from: NSNumber(value: amount)) ?? "0,00"
        return "\(currencySymbol()) \(value)"
    }

    // MARK: Categories (synced from Flutter)
    static func categories() -> [WidgetCategory] {
        guard let raw = defaults?.string(forKey: kCategories),
              let data = raw.data(using: .utf8),
              let arr = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
        else {
            return []
        }

        return arr.compactMap { item in
            guard let id = item["id"] as? String,
                  let name = item["name"] as? String else { return nil }
            let argb = (item["color"] as? Int) ?? 0xFF9E9E9E
            return WidgetCategory(
                id: id,
                name: name,
                color: Color(argb: argb),
                iconCodePoint: item["icon"] as? Int,
                symbol: WidgetStore.symbol(for: id)
            )
        }
    }

    // MARK: Pending queue helpers
    private static func loadQueue() -> [[String: Any]] {
        guard let raw = defaults?.string(forKey: kPending),
              let data = raw.data(using: .utf8),
              let arr = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
        else { return [] }
        return arr
    }

    private static func saveQueue(_ queue: [[String: Any]]) {
        if queue.isEmpty {
            defaults?.removeObject(forKey: kPending)
            return
        }
        if let data = try? JSONSerialization.data(withJSONObject: queue),
           let json = String(data: data, encoding: .utf8) {
            defaults?.set(json, forKey: kPending)
        }
    }

    // MARK: Enqueue expense (category tapped)
    /// Appends the running total under the given category to the pending queue
    /// and resets the running total. The Flutter app drains this on launch.
    /// Also arms the 5s undo window.
    static func enqueueExpense(categoryId: String) {
        let amount = pendingAmount()
        guard amount > 0 else { return }

        var queue = loadQueue()
        queue.append([
            "categoryId": categoryId,
            "amount": amount,
            "date": Date().timeIntervalSince1970 * 1000,
        ])
        saveQueue(queue)

        clearPending()
        armUndo(amount: amount)
    }

    // MARK: Undo
    private static func armUndo(amount: Double) {
        let deadlineMs = (Date().timeIntervalSince1970 + undoWindow) * 1000
        defaults?.set(deadlineMs, forKey: kUndoDeadline)
        defaults?.set(amount, forKey: kUndoAmount)
    }

    static func clearUndo() {
        defaults?.removeObject(forKey: kUndoDeadline)
        defaults?.removeObject(forKey: kUndoAmount)
    }

    /// Deadline do undo se ainda estiver dentro da janela; senão nil.
    static func undoDeadline() -> Date? {
        guard let ms = defaults?.object(forKey: kUndoDeadline) as? Double, ms > 0 else { return nil }
        let date = Date(timeIntervalSince1970: ms / 1000)
        return date > Date() ? date : nil
    }

    /// Remove o último gasto enfileirado e devolve o valor ao total pendente,
    /// para o usuário re-categorizar caso tenha clicado errado.
    static func undoLast() {
        var queue = loadQueue()
        let last = queue.popLast()
        saveQueue(queue)

        let amount = (last?["amount"] as? Double)
            ?? (defaults?.object(forKey: kUndoAmount) as? Double)
            ?? 0
        if amount > 0 {
            defaults?.set(amount, forKey: kPendingAmount)
        }
        clearUndo()
    }

    // MARK: SF Symbol fallback for the built-in categories
    /// Only used until the app syncs the real Material Icons codepoints; ids
    /// mirror CategoryService.dart.
    static func symbol(for id: String) -> String {
        switch id {
        case "Shopping": return "cart.fill"
        case "Home": return "house.fill"
        case "Transport": return "car"
        case "Restaurant": return "fork.knife"
        case "Hospital": return "cross.fill"
        case "GasStation": return "fuelpump.fill"
        case "Drink": return "wineglass.fill"
        case "fun": return "party.popper.fill"
        case "ShoppingBasket": return "basket.fill"
        case "CreditCard": return "creditcard.fill"
        case "Education": return "graduationcap"
        case "Phone": return "phone.fill"
        case "Movie": return "film.fill"
        case "VideoGame": return "gamecontroller.fill"
        case "Unknown": return "questionmark"
        default: return "tag.fill"
        }
    }

    // MARK: Material Icons font
    /// PostScript name of the font bundled with the widget (mirrors the one
    /// Flutter uses for Icons.*).
    static let iconFontName = "MaterialIcons-Regular"
}

// MARK: - App design system palette (mirrors lib/designSystem/Constants/AppColors.dart)
enum WidgetTheme {
    static let background = Color(argb: 0xFF121212)   // AppColors.background1
    static let backgroundTop = Color(argb: 0xFF1A1A1A)
    static let card = Color(argb: 0xFF1A1A1A)         // AppColors.card2 / buttonDeselected
    static let accent = Color(argb: 0xFF007AFF)       // AppColors.button
    static let label = Color.white                    // AppColors.label
    static let labelSecondary = Color(argb: 0xFF8E8E93) // AppColors.labelPlaceholder
    static let deletion = Color(argb: 0xFFE53935)     // AppColors.deletionButton

    // Raios espelhando o app: botão primário usa 16, teclado usa 8.
    static let chipRadius: CGFloat = 14
}

// MARK: - Color from Flutter ARGB int
extension Color {
    init(argb: Int) {
        let a = Double((argb >> 24) & 0xFF) / 255.0
        let r = Double((argb >> 16) & 0xFF) / 255.0
        let g = Double((argb >> 8) & 0xFF) / 255.0
        let b = Double(argb & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a == 0 ? 1 : a)
    }
}

// MARK: - Localized strings (PT / EN / ES)
enum WidgetL10n {
    private static var lang: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    static var quickAdd: String {
        switch lang {
        case "pt": return "Adição rápida"
        case "es": return "Añadir rápido"
        default: return "Quick add"
        }
    }

    static var tapCategory: String {
        switch lang {
        case "pt": return "Some um valor e toque numa categoria"
        case "es": return "Suma un valor y toca una categoría"
        default: return "Add a value, then tap a category"
        }
    }

    static var openApp: String {
        switch lang {
        case "pt": return "Abra o app para configurar"
        case "es": return "Abre la app para configurar"
        default: return "Open the app to set up"
        }
    }

    static var undo: String {
        switch lang {
        case "pt": return "Desfazer"
        case "es": return "Deshacer"
        default: return "Undo"
        }
    }
}
