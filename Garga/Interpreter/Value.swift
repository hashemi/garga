//
//  Value.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

enum Value: Equatable {
    case string(String)
    case number(Int)
    case function([String], Stmt)
    case native([String], (inout [String: Value]) -> Value)

    static let `default` = Value.number(1000)
    static let `true` = Value.number(1)
    static let `false` = Value.number(0)

    var isTruthy: Bool {
        switch self {
        case .string(""): return false
        case .number(0): return false
        default: return true
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let str): return str
        case .number(let num): return String(num)
        default: return nil
        }
    }

    static func == (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhs), .string(rhs)):
            return lhs == rhs
        case let (.number(lhs), .number(rhs)):
            return lhs == rhs
        case let (.number(lhs), .string(rhs)):
            return String(lhs) == rhs
        case let (.string(lhs), .number(rhs)):
            return lhs == String(rhs)
        case _:
            return false
        }
    }
}
