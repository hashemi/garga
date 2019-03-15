//
//  Interpreter.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

struct Interpreter {
    private(set) var variables: [String: Value]
    private var wasta: Bool {
        guard let w = variables["واسطه"] else { return false }
        return w.isTruthy
    }

    mutating func eval(_ s: Stmt) throws -> Value {
        switch s {
        case .expr(let expr):
            return try eval(expr)
            
        case let .if(cond, thenBlock, elseBlock):
            return try eval(cond).isTruthy || wasta ? eval(thenBlock) : eval(elseBlock)
        
        case let .while(cond, body):
            var lastVal = Value.default
            while try eval(cond).isTruthy {
                lastVal = try eval(body)
            }
            return lastVal
            
        case let .function(name, params, body):
            let val = Value.function(params, body)
            variables[name] = val
            return val
            
        case let .block(stmts):
            for s in stmts.dropLast() {
                _ = try eval(s)
            }
            guard let last = stmts.last else { return Value.default }
            return try eval(last)
        }
    }

    private mutating func eval(_ e: Expr) throws -> Value {
        switch e {
        case let .literal(val):
            return val

        case let .variable(name):
            return variables[name, default: Value.default]

        case let .assign(name, expr):
            let val = try eval(expr)
            variables[name] = val
            return val

        case let .unary(op, operand):
            return try unary(op, try eval(operand))

        case let .binary(lhs, op, rhs):
            return try binary(try eval(lhs), op, try eval(rhs))
        
        case let .grouping(expr):
            return try eval(expr)
            
        case let .call(f, args):
            switch try eval(f) {
            case let .function(argNames, body):
                for (name, val) in zip(argNames, args) {
                    variables[name] = try eval(val)
                }
                return try eval(body)

            case let .native(argNames, body):
                for (name, val) in zip(argNames, args) {
                    variables[name] = try eval(val)
                }
                return body(&variables)
                
            default:
                throw GargaError.nonCallable
            }
        }
    }

    private mutating func unary(_ op: Token, _ operand: Value) throws -> Value {
        switch op {
        case .bang:
            return operand.isTruthy ? Value.number(0) : Value.number(1)
        
        case .minus:
            let numToNegate: Int
            switch operand {
            case let .number(n):
                numToNegate = n
                
            case let .string(s):
                numToNegate = Int(s) ?? 0
                
            case .function, .native:
                throw GargaError.unexpectedValue(operand)
            }
            
            return Value.number(-numToNegate)
            
        default:
            fatalError("Non-unary operator in a unary expression")
        }
    }
    
    private mutating func binary(_ lhs: Value, _ op: Token, _ rhs: Value) throws -> Value {
        switch op {
        case .equalEqual: return lhs == rhs ? .true : .false
        case .bangEqual: return lhs != rhs ? .false : .true
        case .plus, .greater, .greaterEqual, .less, .lessEqual: return try binarySameTypeOp(lhs, op, rhs)
        case .minus, .star, .slash: return try binaryIntOp(lhs, op, rhs)

        default: fatalError("Non-binary operator in a binary expression")
        }
    }

    private mutating func binaryIntOp(_ lhs: Value, _ op: Token, _ rhs: Value) throws -> Value {
        guard case let .number(lhsVal) = lhs else {
            throw GargaError.unexpectedValue(lhs)
        }
        guard case let .number(rhsVal) = rhs else {
            throw GargaError.unexpectedValue(rhs)
        }
        
        switch op {
        case .minus: return .number(lhsVal - rhsVal)
        case .star: return .number(lhsVal * rhsVal)
        case .slash: return .number(lhsVal / rhsVal)
        default:
            fatalError("Non-integer operator given")
        }
    }
    
    private mutating func binarySameTypeOp(_ lhs: Value, _ op: Token, _ rhs: Value) throws -> Value {
        switch (lhs, rhs) {
        case let (.number(lhs), .number(rhs)):
            return try binarySameTypeOpPerform(lhs, op, rhs)
            
        case let (.string(lhs), .string(rhs)):
            return try binarySameTypeOpPerform(lhs, op, rhs)

        case let (.number(lhs), .string(rhs)):
            return try binarySameTypeOpPerform(String(lhs), op, rhs)

        case let (.string(lhs), .number(rhs)):
            return try binarySameTypeOpPerform(lhs, op, String(rhs))

        default:
            throw GargaError.unexpectedValue(lhs)
        }
    }

    private mutating func binarySameTypeOpPerform(_ lhs: String, _ op: Token, _ rhs: String) throws -> Value {
        switch op {
        case .plus: return .string(lhs + rhs)
        case .greater: return lhs > rhs ? .true : .false
        case .greaterEqual: return lhs >= rhs ? .true : .false
        case .less: return lhs < rhs ? .true : .false
        case .lessEqual: return lhs <= rhs ? .true : .false
        default:
            fatalError("Non-same type binary operator given")
        }
    }

    private mutating func binarySameTypeOpPerform(_ lhs: Int, _ op: Token, _ rhs: Int) throws -> Value {
        switch op {
        case .plus: return .number(lhs + rhs)
        case .greater: return lhs > rhs ? .true : .false
        case .greaterEqual: return lhs >= rhs ? .true : .false
        case .less: return lhs < rhs ? .true : .false
        case .lessEqual: return lhs <= rhs ? .true : .false
        default:
            fatalError("Non-same type binary operator given")
        }
    }
}
