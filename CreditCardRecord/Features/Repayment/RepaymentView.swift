import SwiftData
import SwiftUI

struct RepaymentView: View {
    @Environment(\.appStrings) private var strings
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CreditCard]
    @Query private var statementCycles: [StatementCycle]
    @Query private var transactions: [TransactionRecord]
    @State private var selectedCardID: UUID?
    @State private var confirmPaid = false
    var onAddCard: () -> Void = {}
    var onSettings: () -> Void = {}
    private var creditCards: [CreditCard] {
        cards.filter(\.requiresRepayment).sorted { cycle($0).dueDate < cycle($1).dueDate }
    }
    private var selected: CreditCard? { creditCards.first { $0.id == selectedCardID } ?? creditCards.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(strings.nextPaymentDue).font(.system(size: 22, weight: .bold, design: .rounded))
                    if creditCards.isEmpty {
                        VStack(alignment: .leading, spacing: 18) {
                            Image(systemName: "calendar.badge.checkmark").font(.system(size: 34)).foregroundStyle(DashboardStyle.primary)
                            Text(strings.noCreditCards).foregroundStyle(DashboardStyle.secondaryText)
                                .accessibilityIdentifier("repayment.noCards")
                            Button(action: onAddCard) { Label(strings.addCard, systemImage: "plus") }.buttonStyle(.bordered)
                        }.padding(.vertical, 24)
                    } else {
                        CardCarousel(cards: creditCards, transactions: transactions, selection: $selectedCardID)
                        if let card = selected {
                            paymentDetails(card)
                        }
                    }
                }.padding(20)
            }
            .background(DashboardBackground().ignoresSafeArea())
            .navigationTitle(strings.repaymentTitle).navigationBarTitleDisplayMode(.inline)
            .toolbar { ScreenActions(onAddCard: onAddCard, onSettings: onSettings) }
            .alert(strings.markPaid, isPresented: $confirmPaid) {
                Button(strings.cancel, role: .cancel) {}
                Button(strings.markPaid) { if let card = selected { markPaid(card) } }
            } message: {
                Text(strings.text("This records the payment status only. No money will be transferred.",
                                  traditional: "此操作只記錄還款狀態，不會轉移款項。", simplified: "此操作只记录还款状态，不会转移款项。"))
            }
        }
    }

    private func paymentDetails(_ card: CreditCard) -> some View {
        let bill = cycle(card)
        let total = RepaymentCalculator.totalDue(for: RepaymentWindow(cardID: card.id, startDate: bill.startDate, endDate: bill.endDate), transactions: transactions)
        let overdue = bill.dueDate < Calendar.current.startOfDay(for: Date())
        let days = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: bill.dueDate).day ?? 0)
        let recorded = statementCycles.contains { $0.cardID == card.id && $0.statementDate == bill.statementDate && $0.isManualDate }
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label(overdue ? strings.overdue : strings.daysLeftSentence(days), systemImage: overdue ? "exclamationmark.circle" : "calendar")
                    .foregroundStyle(overdue ? DashboardStyle.errorText : DashboardStyle.primary)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                if !recorded { Text(strings.estimated).font(.caption).foregroundStyle(DashboardStyle.secondaryText) }
            }
            Text(strings.recordedSpendHKD).font(.caption).foregroundStyle(DashboardStyle.secondaryText)
            MoneyText(amount: total).font(.system(size: 34, weight: .bold, design: .rounded))
            LabeledContent(strings.firstStatement, value: strings.dateString(bill.statementDate, format: "yyyy MMM d"))
            LabeledContent(strings.firstPaymentDue, value: strings.dateString(bill.dueDate, format: "yyyy MMM d"))
            Text(strings.statementDateNotice).font(.footnote).foregroundStyle(DashboardStyle.secondaryText)
            Button { confirmPaid = true } label: {
                Label(strings.markPaid, systemImage: "checkmark.circle").frame(maxWidth: .infinity, minHeight: 46)
            }.buttonStyle(.borderedProminent).tint(DashboardStyle.primary).accessibilityIdentifier("repayment.markPaid")
        }
    }
    private func cycle(_ card: CreditCard) -> PredictedCycle {
        StatementCyclePredictor.upcomingCycle(for: card, cycles: statementCycles)
    }
    private func markPaid(_ card: CreditCard) {
        let bill = cycle(card)
        if let recorded = statementCycles.first(where: { $0.cardID == card.id && $0.statementDate == bill.statementDate }) {
            recorded.isPaid = true
        } else {
            modelContext.insert(StatementCycle(cardID: card.id, startDate: bill.startDate, endDate: bill.endDate,
                                              statementDate: bill.statementDate, dueDate: bill.dueDate, isPaid: true))
        }
    }
}
