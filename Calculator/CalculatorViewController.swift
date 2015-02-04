//
//  ViewController.swift
//  Calculator
//
//  Created by Raissa Largman on 1/5/15.
//  Copyright (c) 2015 Raissa Largman. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()

    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        displayValue = nil
        history.text = " "
        brain = CalculatorBrain()
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." && display.text!.rangeOfString(".") != nil {
            return
        }
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        let symbol = sender.currentTitle!.substringFromIndex(sender.currentTitle!.startIndex.successor())
        if displayValue != nil {
            brain.variableValues[symbol] = displayValue!
            userIsInTheMiddleOfTypingANumber = false
            displayValue = brain.evaluate()
            history.text = brain.description
        }
    }
    
    @IBAction func appendVariable(sender: UIButton) {
        brain.pushOperand(sender.currentTitle!)
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.evaluate()
        history.text = brain.description
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
            history.text = brain.description
        }
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.pushOperand(displayValue!)
        history.text = brain.description
    }
    
    var displayValue: Double? {
        get {
            if display.text! == " " {
                return nil
            }
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue == nil {
                display.text = " "
            } else {
                display.text = "\(newValue!)"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}

