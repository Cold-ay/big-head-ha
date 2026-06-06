import Foundation

struct HongKongCardPreset: Identifiable, Equatable {
    let id: String
    let issuerName: String
    let displayName: String
    let defaultStatementDay: Int
    let defaultDueOffsetDays: Int
}

enum HongKongCardCatalog {
    static let presets: [HongKongCardPreset] = [
        HongKongCardPreset(id: "hsbc-red", issuerName: "HSBC", displayName: "HSBC Red Credit Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hang-seng-enjoy", issuerName: "Hang Seng Bank", displayName: "Hang Seng enJoy Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "standard-chartered-smart", issuerName: "Standard Chartered", displayName: "Standard Chartered Smart Credit Card", defaultStatementDay: 12, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "boc-hk", issuerName: "Bank of China Hong Kong", displayName: "BOC Credit Card", defaultStatementDay: 10, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "citi-cash-back", issuerName: "Citi Hong Kong", displayName: "Citi Cash Back Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-black", issuerName: "DBS Hong Kong", displayName: "DBS Black Card", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "aeon", issuerName: "AEON Credit Service", displayName: "AEON Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "amex", issuerName: "American Express", displayName: "American Express Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dah-sing", issuerName: "Dah Sing Bank", displayName: "Dah Sing Credit Card", defaultStatementDay: 8, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "bea", issuerName: "Bank of East Asia", displayName: "BEA Credit Card", defaultStatementDay: 11, defaultDueOffsetDays: 25)
    ]
}
