//
//  QuickAddWidget.swift
//  MeusGastosQuickAdd
//
//  Interactive home screen widget: value buttons sum into a running total,
//  tapping a category registers the expense (queued for the app to persist).
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Timeline
struct QuickAddEntry: TimelineEntry {
    let date: Date
    let total: Double
    let categories: [WidgetCategory]
    let showUndo: Bool
}

struct QuickAddProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(date: Date(), total: 0, categories: sampleCategories, showUndo: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
        let now = Date()
        var entries = [entry(at: now)]
        // Se há janela de undo ativa, agenda um entry no deadline para o
        // botão voltar a ser "limpar" automaticamente após os 5s.
        if let deadline = WidgetStore.undoDeadline(), deadline > now {
            entries.append(entry(at: deadline))
        }
        completion(Timeline(entries: entries, policy: .never))
    }

    private func entry(at date: Date) -> QuickAddEntry {
        let cats = WidgetStore.categories()
        let deadline = WidgetStore.undoDeadline()
        return QuickAddEntry(
            date: date,
            total: WidgetStore.pendingAmount(),
            categories: cats.isEmpty ? sampleCategories : cats,
            showUndo: deadline != nil && date < deadline!
        )
    }

    private var sampleCategories: [WidgetCategory] {
        [
            WidgetCategory(id: "Restaurant", name: "Food", color: Color(argb: 0xFFB39DDB),
                           iconCodePoint: 0xE532, symbol: "fork.knife"),
            WidgetCategory(id: "GasStation", name: "Fuel", color: Color(argb: 0xFFFFD700),
                           iconCodePoint: 0xE394, symbol: "fuelpump.fill"),
            WidgetCategory(id: "Shopping", name: "Shop", color: Color(argb: 0xFF00E676),
                           iconCodePoint: 0xE59C, symbol: "cart.fill"),
            WidgetCategory(id: "Transport", name: "Car", color: Color(argb: 0xFF2979FF),
                           iconCodePoint: 0xEFC6, symbol: "car"),
        ]
    }
}

// MARK: - Constants
private let valuePresets: [Double] = [5, 10, 50, 100]

// MARK: - Sizing per family
private struct Metrics {
    let totalFont: CGFloat
    let chipHeight: CGFloat
    let chipFont: CGFloat
    let circle: CGFloat
    let iconFont: CGFloat
    let labelFont: CGFloat
    let rowSpacing: CGFloat
    let categoryRows: Int
    let showLabels: Bool

    static func of(_ family: WidgetFamily) -> Metrics {
        if family == .systemLarge {
            return Metrics(totalFont: 27, chipHeight: 46, chipFont: 19,
                           circle: 48, iconFont: 20, labelFont: 10.5,
                           rowSpacing: 13, categoryRows: 3, showLabels: true)
        }
        // Medium: só ícones (sem label) para caber sem cortar.
        return Metrics(totalFont: 21, chipHeight: 36, chipFont: 16.5,
                       circle: 41, iconFont: 18, labelFont: 9.5,
                       rowSpacing: 9, categoryRows: 1, showLabels: false)
    }
}

// MARK: - Entry View
struct QuickAddWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: QuickAddEntry

    private var m: Metrics { Metrics.of(family) }

    private var visibleCategories: [WidgetCategory] {
        Array(entry.categories.prefix(m.categoryRows * 4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: m.rowSpacing) {
            header
            valueRow
            categorySection
            if family == .systemLarge { Spacer(minLength: 0) }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [WidgetTheme.backgroundTop, WidgetTheme.background],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(WidgetTheme.accent)
                    .frame(width: 7, height: 7)
                Text(WidgetStore.formatted(entry.total))
                    .font(.system(size: m.totalFont, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.total > 0 ? WidgetTheme.label : WidgetTheme.labelSecondary.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
            }
            Spacer(minLength: 4)
            if #available(iOS 17.0, *) {
                if entry.showUndo {
                    Button(intent: UndoIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 11, weight: .bold))
                            Text(WidgetL10n.undo)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(WidgetTheme.accent)
                        .padding(.horizontal, 10)
                        .frame(height: 29)
                        .background(WidgetTheme.accent.opacity(0.16), in: Capsule())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(intent: ClearAmountIntent()) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(entry.total > 0 ? WidgetTheme.deletion : WidgetTheme.labelSecondary.opacity(0.4))
                            .frame(width: 29, height: 29)
                            .background(WidgetTheme.card, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(entry.total <= 0)
                }
            }
        }
    }

    // MARK: Value buttons
    private var valueRow: some View {
        HStack(spacing: 7) {
            ForEach(valuePresets, id: \.self) { value in
                if #available(iOS 17.0, *) {
                    Button(intent: AddAmountIntent(amount: value)) {
                        Text("+\(intLabel(value))")
                            .font(.system(size: m.chipFont, weight: .semibold, design: .rounded))
                            .foregroundStyle(WidgetTheme.label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: m.chipHeight)
                            .background(
                                RoundedRectangle(cornerRadius: WidgetTheme.chipRadius, style: .continuous)
                                    .fill(WidgetTheme.card)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: WidgetTheme.chipRadius, style: .continuous)
                                    .stroke(WidgetTheme.accent.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Category buttons
    private var categorySection: some View {
        let cats = visibleCategories
        let rows = stride(from: 0, to: cats.count, by: 4).map { start in
            Array(cats[start..<min(start + 4, cats.count)])
        }
        return VStack(spacing: m.rowSpacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 6) {
                    ForEach(row) { cat in categoryButton(cat) }
                    // Preenche a última linha incompleta para manter o alinhamento.
                    if row.count < 4 {
                        ForEach(0..<(4 - row.count), id: \.self) { _ in
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    /// Same glyph as the app's add-expense screen: the Material Icons codepoint
    /// synced from Flutter, falling back to an SF Symbol if it is missing.
    @ViewBuilder
    private func categoryIcon(_ cat: WidgetCategory) -> some View {
        if let glyph = cat.glyph {
            Text(glyph)
                .font(.custom(WidgetStore.iconFontName, size: m.iconFont * 1.15))
        } else {
            Image(systemName: cat.symbol)
                .font(.system(size: m.iconFont, weight: .semibold))
        }
    }

    @ViewBuilder
    private func categoryButton(_ cat: WidgetCategory) -> some View {
        if #available(iOS 17.0, *) {
            Button(intent: AddExpenseIntent(categoryId: cat.id)) {
                VStack(spacing: 4) {
                    categoryIcon(cat)
                        .foregroundStyle(.white)
                        .frame(width: m.circle, height: m.circle)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [cat.color, cat.color.opacity(0.75)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                        )
                    if m.showLabels {
                        Text(cat.name)
                            .font(.system(size: m.labelFont, weight: .medium))
                            .foregroundStyle(WidgetTheme.labelSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Helpers
    private func intLabel(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

// MARK: - Widget
struct QuickAddWidget: Widget {
    let kind: String = "MeusGastosQuickAdd"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddProvider()) { entry in
            QuickAddWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetL10n.quickAdd)
        .description(WidgetL10n.tapCategory)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
