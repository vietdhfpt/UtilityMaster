//
//  CalculatorKeypad.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/16/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import UIKit

protocol CalculatorKeypadDelegate : class {
    func updateCalculatorLabels(withEquation eqString: String, andResult resultString : String)
}

class CalculatorKeypad: UIViewController {
    
    @IBOutlet weak var keypadCollectionView: UICollectionView!
    var buttonWidth : CGFloat = 66.0
    var buttonHeight : CGFloat = 80.0
    var typedNumber : String = "0"
    var truncatedNumber : String = "0"
    
    var enableMRBtn = false
    
    weak var delegate : CalculatorKeypadDelegate?
    
    let calc = CalculatorCore()
    
    let cellIdentifiers:[String] = ["MemoryClear", "BlankSpace", "CE", "Clear", "BackSpace", "Divide", "MemoryRecall", "Square", "Seven", "Eight", "Nine", "Multiply", "MemoryPlus", "Inverse", "Four", "Five", "Six", "Minus", "MemoryMinus", "SquareRoot", "One", "Two", "Three", "Add", "MemoryStore", "Percentage", "ChangeSign", "Zero", "DecimalPoint", "EqualsTo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keypadCollectionView.backgroundColor = UIColor.init(red: 37.0/255.0, green: 44.0/255.0, blue: 53.0/255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CalculatorKeypad: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK:- UICollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        if let cellID = cell?.reuseIdentifier
        {
            switch cellID {
            case "MemoryClear":
                calc.pressed(CalculatorCoreButton.memoryClear)
            case "MemoryRecall":
                calc.pressed(CalculatorCoreButton.memoryRecall)
            case "MemoryPlus":
                calc.pressed(CalculatorCoreButton.memoryPlus)
            case "MemoryMinus":
                calc.pressed(CalculatorCoreButton.memoryMinus)
            case "MemoryStore":
                calc.pressed(CalculatorCoreButton.memoryStore)
            case "CE":
                calc.pressed(CalculatorCoreButton.clearEntry)
            case "Clear":
                calc.pressed(CalculatorCoreButton.clear)
            case "BackSpace":
                calc.pressed(CalculatorCoreButton.backSpace)
                
            case "Zero":
                calc.pressed(CalculatorCoreButton.digit0)
            case "One":
                calc.pressed(CalculatorCoreButton.digit1)
            case "Two":
                calc.pressed(CalculatorCoreButton.digit2)
            case "Three":
                calc.pressed(CalculatorCoreButton.digit3)
            case "Four":
                calc.pressed(CalculatorCoreButton.digit4)
            case "Five":
                calc.pressed(CalculatorCoreButton.digit5)
            case "Six":
                calc.pressed(CalculatorCoreButton.digit6)
            case "Seven":
                calc.pressed(CalculatorCoreButton.digit7)
            case "Eight":
                calc.pressed(CalculatorCoreButton.digit8)
            case "Nine":
                calc.pressed(CalculatorCoreButton.digit9)
                
            case "Add":
                calc.pressed(CalculatorCoreButton.plus)
            case "Minus":
                calc.pressed(CalculatorCoreButton.minus)
            case "Divide":
                calc.pressed(CalculatorCoreButton.divide)
            case "Multiply":
                calc.pressed(CalculatorCoreButton.multiply)
            case "SquareRoot":
                calc.pressed(CalculatorCoreButton.sqrt)
            case "Square":
                calc.pressed(CalculatorCoreButton.sqr)
            case "Inverse":
                calc.pressed(CalculatorCoreButton.inverse)
            case "Percentage":
                calc.pressed(CalculatorCoreButton.percent)
            case "ChangeSign":
                calc.pressed(CalculatorCoreButton.signChange)
            case "DecimalPoint":
                calc.pressed(CalculatorCoreButton.decimalPoint)
            case "EqualsTo":
                calc.pressed(CalculatorCoreButton.equals)
            default:
                typedNumber = "0"
            }
            typedNumber = calc.displayString
        }
        
        //Disable MC and MR buttons when there's no value in memory
        if self.enableMRBtn != calc.hasValueInMemory {
            //Reload keypad collection view
            self.keypadCollectionView.reloadData()
            self.enableMRBtn =  calc.hasValueInMemory
        }
        //Update results label on calculator VC
        self.delegate?.updateCalculatorLabels(withEquation: calc.equationString, andResult: calc.displayString)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers[indexPath.item], for:indexPath)
        if cell.reuseIdentifier == "MemoryClear" || cell.reuseIdentifier == "MemoryRecall"{
            cell.isUserInteractionEnabled = calc.hasValueInMemory
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return  CGSize(width: buttonWidth, height: buttonHeight)
    }
    
    func updateCollectionViewLayoutForPortrait() {
        let flowLayout = keypadCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        buttonWidth = 66.0
        buttonHeight = 80.0
        flowLayout!.minimumInteritemSpacing = 2
        flowLayout!.minimumLineSpacing = 4
        flowLayout!.invalidateLayout()
        calc.maxDisplayableChars = 10
    }
//
//    func updateCollectionViewLayoutForLandscape() {
//        let flowLayout = keypadCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        buttonWidth = 165.0
//        buttonHeight = 80.0
//        flowLayout!.minimumInteritemSpacing = 2
//        flowLayout!.minimumLineSpacing = 4
//        flowLayout!.invalidateLayout()
//        calc.maxDisplayableChars = 14
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if self.isViewLoaded == true {
            if size.width > size.height {
//                self.updateCollectionViewLayoutForLandscape()
            }
            else{
                self.updateCollectionViewLayoutForPortrait()
            }
        }
        self.delegate?.updateCalculatorLabels(withEquation: calc.equationString, andResult: calc.displayString)
    }
}
