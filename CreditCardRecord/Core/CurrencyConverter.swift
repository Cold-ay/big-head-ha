import Foundation

enum CurrencyConversionError: Error, Equatable {
    case invalidRate
}

enum CurrencyConverter {
    static func convertToHKD(amount: Decimal, rateToHKD: Decimal) throws -> Decimal {
        guard rateToHKD > 0 else { throw CurrencyConversionError.invalidRate }
        return amount * rateToHKD
    }
}
