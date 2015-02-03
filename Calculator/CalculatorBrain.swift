//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Raissa Largman on 1/12/15.
//  Copyright (c) 2015 Raissa Largman. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case ConstantOperation(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.ConstantOperation("π",  M_PI))
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let operand):
                if let value = variableValues[operand] {
                    return (value, remainingOps)
                }
            case .ConstantOperation(_, let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand:Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func getDescription(ops: [Op], parentIsBinary: Bool) -> (result: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .UnaryOperation(let operation, _):
                let operandString = getDescription(remainingOps, parentIsBinary: false)
                let operand = operandString.result
                return ("\(operation)(\(operand))", operandString.remainingOps)
            case .BinaryOperation(let operation, _):
                let op1Evaluation = getDescription(remainingOps, parentIsBinary: true)
                let operand1 = op1Evaluation.result
                let op2Evaluation = getDescription(op1Evaluation.remainingOps, parentIsBinary: true)
                let operand2 = op2Evaluation.result
                if parentIsBinary {
                    return ("(\(operand2) \(operation) \(operand1))", op2Evaluation.remainingOps)
                }
                return (operand2 + " " + operation + " " + operand1, op2Evaluation.remainingOps)
            default:
                return (op.description, remainingOps)
            }
        }
        return (" ", ops)
    }

    
    var description: String {
        get {
            var (result, remainder) = getDescription(opStack, parentIsBinary: false)
            while !remainder.isEmpty {
                let (newResult, newRemainder) = getDescription(remainder, parentIsBinary: false)
                result = "\(newResult), \(result)"
                remainder = newRemainder
            }
            return "\(result) ="
        }
    }
    
}


