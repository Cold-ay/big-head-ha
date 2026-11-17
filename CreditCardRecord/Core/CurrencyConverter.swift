import Foundation

enum CurrencyConversionError: Error, Equatable {
    case invalidRate
}

enum CurrencyConverter {
    static func positiveAmount(_ input: String) -> Decimal? {
        guard let value = Decimal(string: input, locale: Locale(identifier: "en_US_POSIX")), value > 0 else { return nil }
        return value
    }

    static func convertToHKD(amount: Decimal, rateToHKD: Decimal) throws -> Decimal {
        guard rateToHKD > 0 else { throw CurrencyConversionError.invalidRate }
        return amount * rateToHKD
    }
}
