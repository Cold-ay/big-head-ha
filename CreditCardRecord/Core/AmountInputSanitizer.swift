import Foundation

enum AmountInputSanitizer {
    static func sanitize(_ input: String, maximumFractionDigits: Int = 2) -> String {
        let characters = Array(input)
        let decimalSeparatorIndex = preferredDecimalSeparatorIndex(in: characters, maximumFractionDigits: maximumFractionDigits)
        var output = ""
        var fractionDigits = 0

        for (index, character) in characters.enumerated() {
            if character.isNumber {
                if decimalSeparatorIndex != nil && index > decimalSeparatorIndex! {
                    guard fractionDigits < maximumFractionDigits else { continue }
                    fractionDigits += 1
                }
                output.append(character)
            } else if index == decimalSeparatorIndex {
                output.append(".")
            }
        }

        return output
    }

    private static func preferredDecimalSeparatorIndex(in characters: [Character], maximumFractionDigits: Int) -> Int? {
        if let dotIndex = characters.firstIndex(of: ".") {
            return dotIndex
        }

        guard let commaIndex = characters.firstIndex(of: ",") else {
            return nil
        }

        let digitsAfterComma = characters[(commaIndex + 1)...].filter(\.isNumber).count
        guard digitsAfterComma > 0 && digitsAfterComma <= maximumFractionDigits else {
            return nil
        }

        return commaIndex
    }
}
