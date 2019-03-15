//
//  Parser.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

struct Parser {
    private let tokens: [Token]
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    private var peek: Token {
        return tokens[current]
    }

    private var previous: Token {
        return tokens[current - 1]
    }

    private mutating func advance() {
        current += 1
    }

    private mutating func expression() throws -> Expr {
        return try assignment()
    }

    private mutating func match(_ token: Token) -> Bool {
        if peek == token {
            advance()
            return true
        }
        return false
    }
    
    mutating func parse() throws -> Stmt {
        var stmts: [Stmt] = []
        while peek != .eof {
            stmts.append(try statement())
        }
        return .block(stmts)
    }
    
    private mutating func assignment() throws -> Expr {
        let expr = try equality()
        if match(.equal) {
            let equals = previous
            let value = try assignment()
            if case let .variable(name) = expr {
                return .assign(name, value)
            }
            throw GargaError.unexpectedToken(equals)
        }
        return expr
    }

    private mutating func equality() throws -> Expr {
        var expr = try comparison()
        while match(.bangEqual) || match(.equalEqual) {
            let op = previous
            let right = try comparison()
            expr = .binary(expr, op, right)
        }
        return expr
    }

    private mutating func comparison() throws -> Expr {
        var expr = try term()
        while match(.greater) || match(.greaterEqual) || match(.less) || match(.lessEqual) {
            let op = previous
            let right = try term()
            expr = .binary(expr, op, right)
        }
        return expr
    }

    private mutating func term() throws -> Expr {
        var expr = try factor()
        while match(.plus) || match(.minus) {
            let op = previous
            let right = try factor()
            expr = .binary(expr, op, right)
        }
        return expr
    }

    private mutating func factor() throws -> Expr {
        var expr = try unary()
        while match(.slash) || match(.star) {
            let op = previous
            let right = try unary()
            expr = .binary(expr, op, right)
        }
        return expr
    }

    private mutating func unary() throws -> Expr {
        if match(.bang) || match(.minus) {
            let op = previous
            let right = try unary()
            return .unary(op, right)
        }

        return try call()
    }

    private mutating func call() throws -> Expr {
        var expr = try primary()
        var args: [Expr] = []
        if match(.leftParen) {
            if peek != .rightParen {
                repeat {
                    args.append(try expression())
                } while match(.comma)
            }

            guard match(.rightParen) else {
                throw GargaError.unexpectedToken(peek)
            }
            
            expr = .call(expr, args)
        }
        return expr
    }

    private mutating func primary() throws -> Expr {
        let token = peek
        advance()
        switch token {
        case let .number(val): return .literal(.number(val))
        case let .string(val): return .literal(.string(val))
        case let .identifier(id): return .variable(id)
        case .leftParen:
            let expr = try expression()
            guard match(.rightParen) else {
                throw GargaError.unexpectedToken(token)
            }
            return .grouping(expr)
        default:
            throw GargaError.unexpectedToken(token)
        }
    }

    private mutating func statement() throws -> Stmt {
        switch peek {
        case .func:
            advance()
            return try funcDeclaration()
            
        case .if:
            advance()
            return try ifStatement()
            
        case .while:
            advance()
            return try whileStatement()
        
        case .leftBrace:
            advance()
            return try block()
            
        default:
            return try expressionStatement()
        }
    }
    
    private mutating func funcDeclaration() throws -> Stmt {
        guard case let .identifier(name) = peek else {
            throw GargaError.unexpectedToken(peek)
        }
        advance()
        guard match(.leftParen) else {
            throw GargaError.unexpectedToken(peek)
        }
        var params: [String] = []
        if peek != .rightParen {
            repeat {
                guard case let .identifier(paramName) = peek else {
                    throw GargaError.unexpectedToken(peek)
                }
                advance()
                params.append(paramName)
            } while match(.comma)
        }
        guard match(.rightParen) else {
            throw GargaError.unexpectedToken(peek)
        }
        guard match(.leftBrace) else {
            throw GargaError.unexpectedToken(peek)
        }
        let body = try block()
        return .function(name, params, body)
    }
    
    private mutating func ifStatement() throws -> Stmt {
        let cond = try expression()
        guard match(.leftBrace) else { throw GargaError.unexpectedToken(peek) }
        let thenBranch = try block()
        let elseBranch: Stmt
        if match(.else) {
            guard match(.leftBrace) else { throw GargaError.unexpectedToken(peek) }
            elseBranch = try block()
        } else {
            elseBranch = .block([])
        }
        return .if(cond, thenBranch, elseBranch)
    }

    private mutating func whileStatement() throws -> Stmt {
        let cond = try expression()
        guard match(.leftBrace) else { throw GargaError.unexpectedToken(peek) }
        let body = try block()
        return .while(cond, body)
    }

    private mutating func expressionStatement() throws -> Stmt {
        let expr = try expression()
        guard match(.dot) else { throw GargaError.unexpectedToken(peek) }
        return .expr(expr)
    }

    private mutating func block() throws -> Stmt {
        var stmts: [Stmt] = []
        while peek != .rightBrace && peek != .eof {
            stmts.append(try statement())
        }
        guard match(.rightBrace) else { throw GargaError.unexpectedToken(peek) }
        return .block(stmts)
    }
}
