//
//  WidgetIntents.swift
//  MeusGastosQuickAdd
//
//  Interactive AppIntents (iOS 17+) driving the Quick Add widget. All run
//  natively against the shared App Group store — no Flutter engine involved.
//

import AppIntents
import WidgetKit

// MARK: - Add to running total
@available(iOS 17.0, *)
struct AddAmountIntent: AppIntent {
    static var title: LocalizedStringResource = "Add amount"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Amount")
    var amount: Double

    init() {}
    init(amount: Double) { self.amount = amount }

    func perform() async throws -> some IntentResult {
        WidgetStore.addToPending(amount)
        return .result()
    }
}

// MARK: - Clear running total
@available(iOS 17.0, *)
struct ClearAmountIntent: AppIntent {
    static var title: LocalizedStringResource = "Clear amount"
    static var isDiscoverable: Bool = false

    init() {}

    func perform() async throws -> some IntentResult {
        WidgetStore.clearPending()
        WidgetStore.clearUndo()
        return .result()
    }
}

// MARK: - Undo last registered expense
@available(iOS 17.0, *)
struct UndoIntent: AppIntent {
    static var title: LocalizedStringResource = "Undo last expense"
    static var isDiscoverable: Bool = false

    init() {}

    func perform() async throws -> some IntentResult {
        WidgetStore.undoLast()
        return .result()
    }
}

// MARK: - Register expense under a category
@available(iOS 17.0, *)
struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Register expense"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Category")
    var categoryId: String

    init() {}
    init(categoryId: String) { self.categoryId = categoryId }

    func perform() async throws -> some IntentResult {
        WidgetStore.enqueueExpense(categoryId: categoryId)
        return .result()
    }
}
