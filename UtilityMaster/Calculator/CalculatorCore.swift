//
//  CalculatorCore.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/16/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import Foundation

internal extension String {
    fileprivate var lastChar: String {
        get {
            return self.isEmpty ? "" : String(self.characters.last!)
        }
    }
    
    var removingTrailingZeros: String {
        let regex = try! NSRegularExpression(pattern: "\\.0+$|\\.$", options: .caseInsensitive)
        let range = NSMakeRange(0, self.characters.count)
        let newString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        return newString
    }
    
    
    func truncatingTo(_ digits: Int, isDecimal : Bool = false) -> String {
        guard self.characters.count > digits else {
            return self
        }
        let newString = self.substring(to: self.index(startIndex, offsetBy: isDecimal ? digits + 1 : digits))
        return newString
    }
    
    
    fileprivate var double: Double? {
        get {
            return Double(self)
        }
    }
}

enum CalculatorCoreButton {
    case digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9
    case plus, minus, multiply, divide
    case equals
    case signChange
    case decimalPoint
    case sqr, sqrt, inverse, percent
    case memoryStore, memoryRecall, memoryPlus, memoryMinus, memoryClear
    case clear, clearEntry, backSpace
    
    static let allValues: [CalculatorCoreButton] = [.digit0, .digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9, .decimalPoint, .plus, .minus, .multiply, .divide, .equals, .sqr, .sqrt, .percent, .backSpace, .clear, .signChange, .inverse, .clearEntry, .memoryStore, .memoryRecall, .memoryPlus, .memoryMinus, .memoryClear]
    
    var stringValue: String {
        get {
            switch self {
            case .digit0, .digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9:
                return "\(self)".lastChar
            case .decimalPoint:
                return "."
            case .plus:
                return "+"
            case .minus:
                return "-"
            case .multiply:
                return "*"
            case .divide:
                return "/"
            case .equals:
                return "="
            case .sqr:
                return "²"
            case .sqrt:
                return "√"
            case .percent:
                return "%"
            case .backSpace:
                return "⌫"
            case .clear:
                return "C"
            case .clearEntry:
                return "E"
            case .signChange:
                return "±"
            case .inverse:
                return "⅟"
            case .memoryPlus:
                return "p"
            case .memoryClear:
                return "c"
            case .memoryMinus:
                return "m"
            case .memoryStore:
                return "s"
            case .memoryRecall:
                return "r"
            }
        }
    }
    
    func description() -> String {
        return self.stringValue
    }
    
    var modifiesMemory: Bool {
        get {
            return (self == .memoryPlus || self == .memoryMinus || self == .memoryStore)
        }
    }
    
    var isFourFuncOp: Bool {
        get {
            return (self == .plus || self == .minus || self == .multiply || self == .divide)
        }
    }
    
    var isDigit: Bool {
        get {
            switch self {
            case .decimalPoint, .digit0, .digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9:
                return true
            default:
                return false
            }
        }
    }
    
    var clearsError: Bool {
        get {
            return (self == .clear || self == .clearEntry || self == .memoryRecall || self.isDigit)
        }
    }
    
}

internal class CalculatorCore {
    
    // MARK: Exposed properties and methods
    internal var maxDisplayableChars: Int = 10
    
    internal var hasValueInMemory: Bool {
        get {
            return (memory != nil)
        }
    }
    
    internal var displayString: String {
        // Note that getter has side effect of setting flag for the value being entered in reaching max length
        get {
            var formatted = ""
            if let entered = enteredString {
                let stringValue = ((entered.hasPrefix(".") ? "0" : "") + entered).replacingOccurrences(of: "-.", with: "-0.")
                formatted = stringForDisplay(stringValue)
                let maxLen = maxDisplayableChars + (formatted.hasPrefix("-") ? 1 : 0) // Allow for neg value
                enteredStringAtMaxLength = formatted.characters.count >= maxLen
            } else {
                let doubleValue = (x ?? 0.0)
                formatted = stringForDisplay(doubleValue)
                enteredStringAtMaxLength = false
            }
            return formatted
        }
    }
    
    // Useful for debugging only. This used to show the algebraic form of what was entered but that was way to hard to maintain.
    internal var equationString: String {
        get {
            var rv = ""
            if displayExpression {
                if y != nil {
                    rv.append(String(y!).removingTrailingZeros)
                }
                if opStack.count > 1 {
                    rv.append(opStack[1].stringValue)
                }
                if x != nil {
                    rv.append(String(x!).removingTrailingZeros)
                }
                if opStack.count > 0 {
                    rv.append(opStack[0].stringValue)
                }
                if enteredString != nil {
                    rv.append(enteredString!)
                }
            }
            
            if displayDebug {
                let m = memory != nil ? "\(memory!)" : "nil"
                if displayExpression {
                    rv.append(" ")
                }
                rv.append("debug: \"\(enteredString ?? "")\", \(stack), \(opStack.map{$0.stringValue}), M=\(m)")
            }
            return rv
        }
    }
    
    /// Externally exposed method for signaling user button presses
    ///
    /// - Parameter button: Button enumeration pressed
    internal func pressed(_ button: CalculatorCoreButton) {
        if displayString == "Error" {
            if button.clearsError {
                clear()
            } else {
                return
            }
        }
        
        var resetStringForDisplay = true
        
        switch button {
        case .decimalPoint, .digit0, .digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9:
            if !enteredStringAtMaxLength {
                if (lastButton?.modifiesMemory ?? false) {
                    // Memory operations other than recall don't push to stack.
                    enteredString = nil
                }
                digit(button)
            } else {
                resetStringForDisplay = false
            }
        case .plus, .minus, .multiply, .divide:
            operation(button)
        case .equals:
            equals()
        case .clear:
            clear()
        case .clearEntry:
            clearEntry()
        case .sqr, .sqrt, .percent, .inverse:
            postop(button)
        case .signChange:
            changeSign()
        case .memoryPlus, .memoryClear, .memoryMinus, .memoryStore, .memoryRecall:
            memop(button)
        case .backSpace:
            backspace()
        }
        
        lastButton = button
        
        if resetStringForDisplay {
            _stringForDisplay = nil
        }
    }
    
    /// Accepts an array of button presses. Useful mostly for unit test.
    ///
    /// - Parameter buttons: array of buttons to be "pressed" in order
    internal func pressed(_ buttons: [CalculatorCoreButton]) {
        for button in buttons {
            pressed(button)
        }
    }
    
    // MARK: Private properties
    
    /// Converts to a decimal format that should fit in the display
    private var decimalFormatter: NumberFormatter {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumIntegerDigits = maxDisplayableChars - 2
            formatter.maximumSignificantDigits = maxDisplayableChars - 1
            formatter.usesGroupingSeparator = true
            return formatter
        }
    }
    
    /// Converts the value to scientific format
    private var scientificFormatter: NumberFormatter {
        get {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = maxDisplayableChars - 4
            formatter.numberStyle = .scientific
            return formatter
        }
    }
    
    /// Calulates the max displayable value when the number of commas needed are taken into account
    private var maxValueForStandardNotation: Double {
        get {
            let numberOfCommas = Int(maxDisplayableChars / 3) - 1
            let value: Double = NSDecimalNumber(decimal: pow(10, maxDisplayableChars - numberOfCommas)).doubleValue - 1.0
            return value
        }
    }
    
    private let displayDebug = false
    
    private let displayExpression = false
    
    private var enteredString: String?
    
    private var enteredStringAtMaxLength = false
    
    private var memory: Double?
    
    private var stack: [Double] = []
    
    private var opStack: [CalculatorCoreButton] = []
    
    private var lastButton: CalculatorCoreButton?
    
    // MARK: Stack operations
    
    private var x: Double? {
        get {
            if stack.count > 0 {
                return stack[0]
            }
            return nil
        }
        set {
            if let value = newValue {
                if stack.count == 0 {
                    push(value)
                } else {
                    stack[0] = (value == -0 ? 0 : value)
                }
            }
        }
    }
    
    private var y: Double? {
        get {
            if stack.count > 1 {
                return stack[1]
            } else {
                return nil
            }
        }
    }
    
    private func push(_ value: Double) {
        stack.insert((value == -0 ? 0 : value), at: 0)
    }
    
    private func pop() -> Double? {
        if stack.count > 0 {
            let popped = x
            stack.remove(at: 0)
            return popped
        } else {
            return nil
        }
    }
    
    // Perform any muliplications available on stack
    private func stackReduceMultiply() {
        if stack.count > 1 {
            if opStack.count > 0 {
                switch opStack[0] {
                case .multiply:
                    x = y! * pop()!
                    opStack.remove(at: 0)
                case .divide:
                    x = y! / pop()!
                    opStack.remove(at: 0)
                default:
                    break
                }
            }
        }
    }
    
    // Perform addtion operations on stack
    private func stackReduceAdd() {
        if stack.count > 1 {
            if opStack.count > 0 {
                switch opStack.last! {
                case .plus:
                    x = y! + pop()!
                    opStack.removeLast()
                case .minus:
                    x = y! - pop()!
                    opStack.removeLast()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: Key press evaluation
    
    private func digit(_ button: CalculatorCoreButton) {
        if enteredString == nil {
            if x != nil && opStack.count == 0 {
                stack = [Double]()
            }
            enteredString = button.stringValue
        } else {
            if button != .decimalPoint || !enteredString!.contains(".") {
                enteredString = enteredString! + button.stringValue
            }
        }
    }
    
    private func operation(_ button: CalculatorCoreButton) {
        pushEnteredValue()
        if x != nil {
            stackReduceMultiply()
            opStack.insert(button, at: 0)
            if button != .multiply && button != .divide {
                stackReduceAdd();
            }
        }
    }
    
    private func equals() {
        pushEnteredValue()
        stackReduceMultiply()
        stackReduceAdd()
        opStack = []
    }
    
    private func clear() {
        enteredString = nil
        stack = []
        opStack = []
    }
    
    private func clearEntry() {
        if enteredString != nil {
            enteredString = "0"
        } else {
            clear()
        }
    }
    
    private func postop(_ button: CalculatorCoreButton) {
        pushEnteredValue()
        if let value = x {
            switch button {
            case .sqr:
                x = value * value
            case .sqrt:
                x = sqrt(value)
            case .inverse:
                x = 1.0/value
            case .percent:
                x = value/100.0
            default:
                fatalError("Unimplemented post operation \(button.stringValue)")
            }
        }
    }
    
    private func memop(_ button: CalculatorCoreButton) {
        let current = (memory ?? 0.0)
        switch button {
        case .memoryRecall:
            enteredString = nil
            push(current)
        case .memoryStore:
            if enteredString != nil {
                memory = (Double(enteredString!) ?? 0.0)
            } else {
                memory = (x ?? 0.0)
            }
        case .memoryMinus:
            if enteredString != nil {
                memory = current - (Double(enteredString!) ?? 0.0)
            } else {
                memory = current - (x ?? 0.0)
            }
        case .memoryPlus:
            if enteredString != nil {
                memory = current + (Double(enteredString!) ?? 0.0)
            } else {
                memory = current + (x ?? 0.0)
            }
        case .memoryClear:
            memory = nil
        default:
            fatalError("Unimplemented memory operation \(button.stringValue)")
        }
    }
    
    private func changeSign() {
        if enteredString == nil {
            if (lastButton?.isFourFuncOp ?? false) {
                enteredString = "-0"
            } else {
                if let value = x {
                    if x == 0 {
                        _ = pop()
                        enteredString = "-0"
                    } else {
                        x = value * -1.0
                    }
                } else {
                    enteredString = "-0"
                }
            }
        }
        else {
            if enteredString!.hasPrefix("-") {
                enteredString!.remove(at: enteredString!.startIndex)
            } else {
                enteredString = "-" + enteredString!
            }
        }
    }
    
    private func backspace() {
        if enteredString != nil {
            enteredString = String(enteredString!.characters.dropLast())
            if enteredString! == "" || enteredString! == "-"  {
                enteredString = nil
            }
        }
    }
    
    private func pushEnteredValue() {
        if let entered = enteredString {
            if let value = entered.double {
                push(value)
                enteredString = nil
            }
        } else {
            // Edge case where nothing has been entered and the stack is empty (Right after clearing.)
            if stack.count == 0 {
                x = 0
            }
        }
    }
    
    // MARK: Display string formatting
    
    // Formats the passed string for the display. This will retain any trailing zeros. (E.g., "0.00" will not be truncated to just "0")
    private var _stringForDisplay: String?
    
    private func stringForDisplay(_ stringValue: String) -> String {
        if _stringForDisplay == nil {
            var formatted = stringValue
            let decimalAndFraction = formatted.components(separatedBy: ".")
            if decimalAndFraction.count == 2 {
                if let decimal = Double(decimalAndFraction.first!) {
                    if let formattedDecimalString = decimalFormatter.string(from: NSNumber(value: decimal)) {
                        formatted = formattedDecimalString + "." + decimalAndFraction.last!
                        formatted = formatted.truncatingTo(maxDisplayableChars, isDecimal: true)
                    }
                }
            } else {
                let doubleValue = Double(stringValue)
                formatted = decimalFormatter.string(from: NSNumber(value: doubleValue!)) ?? "Error"
            }
            _stringForDisplay = formatted
        }
        return _stringForDisplay!
    }
    
    // Formats a double value to fit in the display. Uneeded trailing zeros will be removed.
    private func stringForDisplay(_ doubleValue: Double) -> String {
        if doubleValue.isInfinite || doubleValue.isNaN {
            return "Error"
        }
        
        var formatted = String(doubleValue);
        if doubleValue > maxValueForStandardNotation || doubleValue < -maxValueForStandardNotation || formatted.contains("e") {
            formatted = scientificFormatter.string(from: NSNumber(value: doubleValue)) ?? "Error"
        } else {
            formatted = stringForDisplay(formatted).removingTrailingZeros
        }
        
        return formatted
    }
    
}
