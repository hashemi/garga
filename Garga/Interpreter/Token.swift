//
//  Token.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

enum Token: Equatable {
    case eof
    case equal, equalEqual, bang, bangEqual, greater, greaterEqual, less, lessEqual
    case plus, minus, star, slash, dot, comma
    case leftParen, rightParen, leftBrace, rightBrace
    case `if`, `else`, `while`, `func`
    case number(Int)
    case string(String)
    case identifier(String)
    
    init?(keyword: String) {
        switch keyword {
        case "لو": self = .if
        case "غيرىذي": self = .else
        case "طولما": self = .while
        case "داله": self = .func
        default:
            return nil
        }
    }
}
