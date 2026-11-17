import Foundation

enum CardRemovalSummary {
    static func linkedTransactionCount(for card: CreditCard, in transactions: [TransactionRecord]) -> Int {
        transactions.filter { $0.cardID == card.id }.count
    }

    static func linkedStatementCycles(for card: CreditCard, in statementCycles: [StatementCycle]) -> [StatementCycle] {
        statementCycles.filter { $0.cardID == card.id }
    }

    static func linkedStatementCycleCount(for card: CreditCard, in statementCycles: [StatementCycle]) -> Int {
        linkedStatementCycles(for: card, in: statementCycles).count
    }

    static func confirmationMessage(for card: CreditCard, in transactions: [TransactionRecord], statementCycles: [StatementCycle] = [], language: AppLanguage = .system) -> String {
        let transactionCount = linkedTransactionCount(for: card, in: transactions)
        let cycleCount = linkedStatementCycleCount(for: card, in: statementCycles)
        guard transactionCount > 0 || cycleCount > 0 else {
            switch language {
            case .system:
                return "Remove \(card.displayName)? This cannot be undone."
            case .traditionalChinese:
                return "要移除 \(card.displayName) 嗎？此操作無法復原。"
            case .simplifiedChinese:
                return "要移除 \(card.displayName) 吗？此操作无法撤销。"
            }
        }

        if cycleCount == 0 {
            let noun = transactionCount == 1 ? "transaction" : "transactions"
            switch language {
            case .system:
                return "This card has \(transactionCount) linked \(noun). Removing the card keeps the \(noun) in history, but it will no longer appear under this card."
            case .traditionalChinese:
                return "此卡有 \(transactionCount) 筆已連結交易。移除卡片後，交易會保留在歷史紀錄中，但不會再顯示於此卡下。"
            case .simplifiedChinese:
                return "此卡有 \(transactionCount) 笔已关联交易。移除卡片后，交易会保留在历史记录中，但不会再显示于此卡下。"
            }
        }

        var details = [String]()
        if transactionCount > 0 {
            let noun = transactionCount == 1 ? "transaction" : "transactions"
            details.append("\(transactionCount) linked \(noun)")
        }
        if cycleCount > 0 {
            let noun = cycleCount == 1 ? "upcoming repayment" : "upcoming repayments"
            details.append("\(cycleCount) \(noun)")
        }

        let historyNote = transactionCount > 0 ? " Transaction history will be kept." : ""
        switch language {
        case .system:
            return "This card has \(details.joined(separator: " and ")). Removing the card also removes its upcoming repayments.\(historyNote)"
        case .traditionalChinese:
            let transactionDetail = transactionCount > 0 ? "\(transactionCount) 筆已連結交易" : nil
            let cycleDetail = cycleCount > 0 ? "\(cycleCount) 筆即將還款" : nil
            let joinedDetails = [transactionDetail, cycleDetail].compactMap { $0 }.joined(separator: " 和 ")
            let history = transactionCount > 0 ? "交易歷史會保留。" : ""
            return "此卡有 \(joinedDetails)。移除卡片亦會移除其即將還款。\(history)"
        case .simplifiedChinese:
            let transactionDetail = transactionCount > 0 ? "\(transactionCount) 笔已关联交易" : nil
            let cycleDetail = cycleCount > 0 ? "\(cycleCount) 笔即将还款" : nil
            let joinedDetails = [transactionDetail, cycleDetail].compactMap { $0 }.joined(separator: " 和 ")
            let history = transactionCount > 0 ? "交易历史会保留。" : ""
            return "此卡有 \(joinedDetails)。移除卡片也会移除其即将还款。\(history)"
        }
    }
}
