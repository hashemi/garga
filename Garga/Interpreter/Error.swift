//
//  Error.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

enum GargaError: Error {
    case unknownCharacter(UnicodeScalar)
    case unterminatedString
    case unexpectedToken(Token)
    case nonCallable
    case unexpectedValue(Value)
}
