//
//  Scanner.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

struct Scanner {
    private let source: String
    private var current: String.UnicodeScalarView.Index

    init(source: String) {
        self.source = source
        self.current = source.unicodeScalars.startIndex
    }

    private var isAtEnd: Bool {
        return current >= source.unicodeScalars.endIndex
    }

    private var peek: UnicodeScalar {
        guard current < source.unicodeScalars.endIndex else {
            return "\0"
        }
        
        return source.unicodeScalars[current]
    }
    
    private mutating func advance() {
        current = source.unicodeScalars.index(after: current)
    }

    private mutating func advance(while cond: (UnicodeScalar) -> Bool) {
        while !isAtEnd && cond(peek) { advance() }
    }

    private mutating func match(_ scalar: UnicodeScalar) -> Bool {
        if peek == scalar {
            advance()
            return true
        }
        return false
    }

    private mutating func skipWhitespace() {
        advance() { $0.isWhitespace }
    }

    mutating func nextToken() throws -> Token {
        skipWhitespace()
        guard !isAtEnd else { return .eof }

        let start = current
        var text: String {
            return String(source.unicodeScalars[start..<current])
        }
        
        let c = peek
        advance()

        switch c {
        case "=": return match("=") ? .equalEqual : .equal
        case "!": return match("=") ? .bangEqual : .bang
        case ">": return match("=") ? .greaterEqual : .greater
        case "<": return match("=") ? .lessEqual : .less
        case "+": return .plus
        case "-": return .minus
        case "*": return .star
        case "/": return .slash
        case ".": return .dot
        case ",": return .comma
        case "(": return .leftParen
        case ")": return .rightParen
        case "{": return .leftBrace
        case "}": return .rightBrace
        case "\"":
            advance() { $0 != "\"" }
            guard !isAtEnd else { throw GargaError.unterminatedString }
            advance() // move over the training "
            var str = text

            // remove the enclosing quotes
            str.removeFirst()
            str.removeLast()

            return .string(str)

        case _ where c.isArabicAlpha:
            advance() { $0.isArabicAlpha || $0 == "_" }
            let id = text.normalized
            return Token(keyword: id) ?? .identifier(id)

        case _ where c.isDigit:
            advance() { $0.isDigit }
            let digits = text.normalized
            return .number(Int(digits)!)
        
        default:
            throw GargaError.unknownCharacter(c)
        }
    }
}

fileprivate extension UnicodeScalar {
    var isWhitespace: Bool {
        return self == " " || self == "\t" || self == "\n" || self == "\r"
    }
    
    var isArabicAlpha: Bool {
        return "ء" <= self && self <= "ي"
    }
    
    var isDigit: Bool {
        return ("0" <= self && self <= "9") || ("٠" <= self && self <= "٩")
    }
    
    var normalized: UnicodeScalar {
        if "٠" <= self && self <= "٩" {
            let indianZero: UnicodeScalar = "٠"
            let arabicZero: UnicodeScalar = "0"
            let newValue = self.value - indianZero.value + arabicZero.value
            return UnicodeScalar(newValue)!
        } else {
            switch self {
            case "ق": return "غ"
            case "ي": return "ى"
            case "ج": return "ى"
            case "ض": return "ظ"
            case "ة": return "ه"
            case "إ": return "ا"
            case "أ": return "ا"
            case "ئ": return "ا"
            case "ء": return "ا"
            case "آ": return "ا"
            case "ؤ": return "ا"
            default: return self
            }
        }
    }
}

fileprivate extension String {
    var normalized: String {
        return String(UnicodeScalarView(unicodeScalars.map({ $0.normalized })))
    }
}
