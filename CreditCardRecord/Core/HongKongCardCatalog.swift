import Foundation

enum CardMarket: String, CaseIterable, Identifiable {
    case hongKong = "HK"
    case taiwan = "TW"

    var id: String { rawValue }
    var currencyCode: String { self == .taiwan ? "TWD" : "HKD" }
}

enum PaymentCardKind: String, CaseIterable {
    case credit
    case debit
    case storedValue
}

struct HongKongCardPreset: Identifiable, Equatable {
    let id: String
    let issuerName: String
    let displayName: String
    let defaultStatementDay: Int
    let defaultDueOffsetDays: Int

    var market: CardMarket { id.hasPrefix("tw-") ? .taiwan : .hongKong }
    var currencyCode: String { market.currencyCode }
    var kind: PaymentCardKind {
        switch id {
        case "za-card", "mox-card": .debit
        case "octopus-card", "tw-easycard": .storedValue
        default: .credit
        }
    }
    var sourceURL: URL? { URL(string: CardCatalog.officialSources[issuerName] ?? "") }
}

enum HongKongCardCatalog {
    static let presets: [HongKongCardPreset] = [
        HongKongCardPreset(id: "hsbc-red", issuerName: "HSBC", displayName: "HSBC Red Credit Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-everymile", issuerName: "HSBC", displayName: "HSBC EveryMile Credit Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-visa-signature", issuerName: "HSBC", displayName: "HSBC Visa Signature Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-easy", issuerName: "HSBC", displayName: "HSBC easy Credit Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-premier-mastercard", issuerName: "HSBC", displayName: "HSBC Premier Mastercard", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-pulse-dual-currency", issuerName: "HSBC", displayName: "HSBC Pulse UnionPay Dual Currency Diamond Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-visa-gold-students", issuerName: "HSBC", displayName: "HSBC Visa Gold Card for Students", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-visa-gold", issuerName: "HSBC", displayName: "HSBC Visa Gold Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hsbc-unionpay-dual-currency", issuerName: "HSBC", displayName: "HSBC UnionPay Dual Currency Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hang-seng-mmpower", issuerName: "Hang Seng Bank", displayName: "Hang Seng MMPOWER World Mastercard", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hang-seng-travel-plus", issuerName: "Hang Seng Bank", displayName: "Hang Seng Travel+ Visa Signature Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "hang-seng-enjoy", issuerName: "Hang Seng Bank", displayName: "Hang Seng enJoy Visa Platinum Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "standard-chartered-cathay", issuerName: "Standard Chartered", displayName: "Standard Chartered Cathay Mastercard", defaultStatementDay: 12, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "standard-chartered-smart", issuerName: "Standard Chartered", displayName: "Standard Chartered Smart Card", defaultStatementDay: 12, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "standard-chartered-simply-cash", issuerName: "Standard Chartered", displayName: "Standard Chartered Simply Cash Visa Card", defaultStatementDay: 12, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "standard-chartered-apoint", issuerName: "Standard Chartered", displayName: "Standard Chartered A.Point Card", defaultStatementDay: 12, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "citi-prestige", issuerName: "Citi Hong Kong", displayName: "Citi Prestige Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-premiermiles", issuerName: "Citi Hong Kong", displayName: "Citi PremierMiles Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-cash-back", issuerName: "Citi Hong Kong", displayName: "Citi Cash Back Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-rewards", issuerName: "Citi Hong Kong", displayName: "Citi Rewards Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-rewards-unionpay", issuerName: "Citi Hong Kong", displayName: "Citi Rewards UnionPay Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-plus", issuerName: "Citi Hong Kong", displayName: "Citi Plus Credit Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-octopus-platinum", issuerName: "Citi Hong Kong", displayName: "Citi Octopus Platinum Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-hktvmall", issuerName: "Citi Hong Kong", displayName: "Citi HKTVmall Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "citi-the-club", issuerName: "Citi Hong Kong", displayName: "Citi The Club Credit Card", defaultStatementDay: 18, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "boc-bliss", issuerName: "Bank of China Hong Kong", displayName: "BOC Bliss Card", defaultStatementDay: 10, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "boc-cheers", issuerName: "Bank of China Hong Kong", displayName: "BOC Cheers Card", defaultStatementDay: 10, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "boc-chill", issuerName: "Bank of China Hong Kong", displayName: "BOC Chill Card", defaultStatementDay: 10, defaultDueOffsetDays: 26),
        HongKongCardPreset(id: "dbs-black-world-mastercard", issuerName: "DBS Hong Kong", displayName: "DBS Black World Mastercard", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-eminent", issuerName: "DBS Hong Kong", displayName: "DBS Eminent Card", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-compass-visa", issuerName: "DBS Hong Kong", displayName: "DBS COMPASS VISA", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-live-fresh", issuerName: "DBS Hong Kong", displayName: "DBS Live Fresh Card", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-black-amex", issuerName: "DBS Hong Kong", displayName: "DBS Black American Express Card", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "dbs-visa-business", issuerName: "DBS Hong Kong", displayName: "DBS VISA Business Card", defaultStatementDay: 20, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "primecredit-earnmore", issuerName: "PrimeCredit", displayName: "EarnMORE Visa Credit Card", defaultStatementDay: 14, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "primecredit-earnmore-unionpay", issuerName: "PrimeCredit", displayName: "EarnMORE UnionPay Credit Card", defaultStatementDay: 14, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "primecredit-wewa", issuerName: "PrimeCredit", displayName: "WeWa Visa Platinum Credit Card", defaultStatementDay: 14, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "primecredit-wewa-visa-signature", issuerName: "PrimeCredit", displayName: "WeWa Visa Signature Credit Card", defaultStatementDay: 14, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "primecredit-wewa-unionpay", issuerName: "PrimeCredit", displayName: "WeWa UnionPay Diamond Credit Card", defaultStatementDay: 14, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "aeon-unionpay", issuerName: "AEON Credit Service", displayName: "AEON UnionPay Credit Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-visa", issuerName: "AEON Credit Service", displayName: "AEON Visa Credit Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-jcb", issuerName: "AEON Credit Service", displayName: "AEON JCB Credit Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-wakuwaku", issuerName: "AEON Credit Service", displayName: "AEON CARD WAKUWAKU", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-mastercard", issuerName: "AEON Credit Service", displayName: "AEON Mastercard Credit Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-jal", issuerName: "AEON Credit Service", displayName: "AEON Card JAL", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-premium-visa", issuerName: "AEON Credit Service", displayName: "AEON Card Premium Visa", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-premium-mastercard", issuerName: "AEON Credit Service", displayName: "AEON Card Premium Mastercard", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-premium-unionpay", issuerName: "AEON Credit Service", displayName: "AEON Card Premium UnionPay", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-watami-visa", issuerName: "AEON Credit Service", displayName: "Watami Visa Card", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-drmax-titanium-mastercard", issuerName: "AEON Credit Service", displayName: "DR-MAX Titanium Mastercard", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-spca-puppy", issuerName: "AEON Credit Service", displayName: "SPCA Mastercard - Puppy", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "aeon-spca-kitten", issuerName: "AEON Credit Service", displayName: "SPCA Mastercard - Kitten", defaultStatementDay: 5, defaultDueOffsetDays: 24),
        HongKongCardPreset(id: "amex-platinum-card", issuerName: "American Express", displayName: "The Platinum Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-explorer", issuerName: "American Express", displayName: "American Express Explorer Credit Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-platinum-credit", issuerName: "American Express", displayName: "American Express Platinum Credit Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-blue-cash", issuerName: "American Express", displayName: "Blue Cash Credit Card from American Express", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-essential", issuerName: "American Express", displayName: "American Express Essential Credit Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-gold-credit", issuerName: "American Express", displayName: "American Express Gold Credit Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-credit", issuerName: "American Express", displayName: "American Express Credit Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-peninsula-platinum", issuerName: "American Express", displayName: "American Express Peninsula Platinum Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-peninsula-gold", issuerName: "American Express", displayName: "American Express Peninsula Gold Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-gold-card", issuerName: "American Express", displayName: "American Express Gold Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-card", issuerName: "American Express", displayName: "American Express Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-corporate", issuerName: "American Express", displayName: "American Express Corporate Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-gold-corporate", issuerName: "American Express", displayName: "American Express Gold Corporate Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-gold-business", issuerName: "American Express", displayName: "American Express Gold Business Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-business", issuerName: "American Express", displayName: "American Express Business Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-classic-corporate", issuerName: "American Express", displayName: "American Express Classic Corporate Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "amex-elite-corporate", issuerName: "American Express", displayName: "American Express Elite Corporate Card", defaultStatementDay: 22, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "za-card", issuerName: "ZA Bank", displayName: "ZA Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "mox-credit", issuerName: "Mox Bank", displayName: "Mox Credit", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "mox-card", issuerName: "Mox Bank", displayName: "Mox Card", defaultStatementDay: 15, defaultDueOffsetDays: 25),
        HongKongCardPreset(id: "octopus-card", issuerName: "Octopus", displayName: "Octopus Card", defaultStatementDay: 15, defaultDueOffsetDays: 25)
    ]

    static var issuerNames: [String] {
        presets.reduce(into: [String]()) { issuers, preset in
            guard !issuers.contains(preset.issuerName) else { return }
            issuers.append(preset.issuerName)
        }
    }

    static func presets(for issuerName: String) -> [HongKongCardPreset] {
        presets.filter { $0.issuerName == issuerName }
    }

    static func defaultPreset(for issuerName: String) -> HongKongCardPreset? {
        presets(for: issuerName).first
    }
}

enum CardCatalog {
    static let researchedOn = "2026-11-18"

    // Dates in presets are form suggestions, never issuer repayment guarantees.
    static let taiwanPresets: [HongKongCardPreset] = [
        taiwan("cathay-cube", "國泰世華銀行", "CUBE信用卡"),
        taiwan("cathay-eva", "國泰世華銀行", "長榮航空聯名卡"),
        taiwan("ctbc-line-pay", "中國信託", "LINE Pay信用卡"),
        taiwan("esun-unicard", "玉山銀行", "玉山Unicard"),
        taiwan("esun-u-bear", "玉山銀行", "玉山U Bear信用卡"),
        taiwan("taishin-richart", "台新銀行", "台新Richart卡"),
        taiwan("fubon-j", "台北富邦銀行", "富邦J卡"),
        taiwan("fubon-momo", "台北富邦銀行", "momo聯名卡"),
        taiwan("sinopac-dawho", "永豐銀行", "DAWHO現金回饋信用卡"),
        taiwan("sinopac-sport", "永豐銀行", "永豐SPORT卡"),
        taiwan("dbs-eco", "星展銀行（台灣）", "星展eco永續卡"),
        taiwan("ubot-line-bank", "聯邦銀行", "聯邦LINE Bank聯名卡"),
        taiwan("ubot-jiho", "聯邦銀行", "聯邦吉鶴卡"),
        taiwan("hsbc-cashback-titanium", "滙豐（台灣）", "滙豐匯鑽卡"),
        taiwan("hsbc-cashback-signature", "滙豐（台灣）", "現金回饋御璽卡"),
        taiwan("easycard", "悠遊卡公司", "悠遊卡 EasyCard")
    ]

    static var allPresets: [HongKongCardPreset] { HongKongCardCatalog.presets + taiwanPresets }
    static func presets(in market: CardMarket) -> [HongKongCardPreset] {
        market == .hongKong ? HongKongCardCatalog.presets : taiwanPresets
    }
    static func issuerNames(in market: CardMarket) -> [String] {
        presets(in: market).reduce(into: []) { names, preset in
            if !names.contains(preset.issuerName) { names.append(preset.issuerName) }
        }
    }
    static func preset(id: String?) -> HongKongCardPreset? {
        allPresets.first { $0.id == id }
    }
    private static func taiwan(_ id: String, _ issuer: String, _ name: String) -> HongKongCardPreset {
        HongKongCardPreset(id: "tw-" + id, issuerName: issuer, displayName: name,
                          defaultStatementDay: 15, defaultDueOffsetDays: 25)
    }

    static let officialSources: [String: String] = [
        "悠遊卡公司": "https://www.easycard.com.tw/easycard?cls=1515395053&id=1507272299",
        "HSBC": "https://www.hsbc.com.hk/credit-cards/",
        "Hang Seng Bank": "https://www.hangseng.com/en-hk/personal/cards/overview/",
        "Standard Chartered": "https://www.sc.com/hk/credit-cards/",
        "Citi Hong Kong": "https://www.citibank.com.hk/en/credit-cards/index.html",
        "Bank of China Hong Kong": "https://www.bochk.com/dam/boccreditcard/cardproductlisting/eng/index.html",
        "DBS Hong Kong": "https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page",
        "PrimeCredit": "https://www.primecredit.com/credit-card/",
        "AEON Credit Service": "https://www.aeon.com.hk/tc/credit-card/card-type.html",
        "American Express": "https://www.americanexpress.com/hk/en/credit-cards/all-cards/",
        "ZA Bank": "https://bank.za.group/en/za-card",
        "Mox Bank": "https://mox.com/features/smart-spending/",
        "Octopus": "https://www.octopus.com.hk/en/consumer/octopus-cards/about/index.html",
        "國泰世華銀行": "https://www.cathay-cube.com.tw/cathaybk/personal/product/credit-card/cards",
        "中國信託": "https://www.ctbcbank.com/web/content/twrbo/zh_tw/cc_index/cc_product/cc_introduction_index/C_LINEPay.html",
        "玉山銀行": "https://www.esunbank.com/zh-tw/personal/credit-card/intro",
        "台新銀行": "https://www.taishinbank.com.tw/TSB/personal/credit/intro/overview/cg047/",
        "台北富邦銀行": "https://www.fubon.com/banking/personal/credit_card/all_card/all_card.htm",
        "永豐銀行": "https://bank.sinopac.com/sinopacBT/personal/credit-card/introduction/DAWHO.html",
        "星展銀行（台灣）": "https://www.dbs.com.tw/personal-zh/cards/dbs_eco/index.html",
        "聯邦銀行": "https://activity.ubot.com.tw/aws_act/2026/2026threecard_apply/index.htm",
        "滙豐（台灣）": "https://www.hsbc.com.tw/credit-cards/"
    ]
}
