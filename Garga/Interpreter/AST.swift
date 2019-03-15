//
//  AST.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

indirect enum Expr {
    case assign(String, Expr)
    case variable(String)
    case binary(Expr, Token, Expr)
    case unary(Token, Expr)
    case call(Expr, [Expr])
    case literal(Value)
    case grouping(Expr)
}

indirect enum Stmt {
    case `if`(Expr, Stmt, Stmt)
    case `while`(Expr, Stmt)
    case expr(Expr)
    case block([Stmt])
    case function(String, [String], Stmt)
}
