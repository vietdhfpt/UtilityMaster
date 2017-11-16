//
//  KeypadButtonCell.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/16/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import UIKit

enum UtilityButtonType {
    case Numbers
    case SingleOperator
    case EqualTo
}

class KeypadButtonCell: UICollectionViewCell {
    @IBOutlet weak var buttonTitleLabel: UILabel!
    
    var buttonTitle: String = "0"
    var cellBGColor = UIColor.clear
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    let darkGreyButtonIds =  ["Divide", "Multiply","Minus", "Add", "ButtonChangeSign",  "ButtonAC", "ButtonBack", "ButtonSwap", "EqualsTo"]
    let clearBGButtonIds = ["MemoryClear", "BlankSpace", "MemoryRecall", "Square", "MemoryPlus", "Inverse", "MemoryMinus", "SquareRoot","MemoryStore", "Percentage"]
    
    override var isHighlighted: Bool{
        didSet {
            if isHighlighted == true {
                self.contentView.backgroundColor = UIColor(red: 57/255, green: 116/255, blue: 188/255, alpha: 1.0)
            } else {
                self.contentView.backgroundColor = cellBGColor
            }
        }
    }
    
    override var isUserInteractionEnabled: Bool{
        didSet{
            
            if self.reuseIdentifier == "MemoryRecall" || self.reuseIdentifier == "MemoryClear" {
                if isUserInteractionEnabled == false {
                    self.buttonTitleLabel.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
                }
                else{
                    self.buttonTitleLabel.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        if darkGreyButtonIds.contains(self.reuseIdentifier!)
        {
            
            cellBGColor = UIColor(red: 45/255, green: 51/255, blue: 61/255, alpha: 1.0)
        }
        else if clearBGButtonIds.contains(self.reuseIdentifier!)
        {
            
            cellBGColor = UIColor.clear
        }
        else{
            cellBGColor = UIColor(red: 60/255, green: 68/255, blue: 78/255, alpha: 1.0)
        }
        
        self.contentView.backgroundColor = cellBGColor
        self.contentView.layer.cornerRadius = 4
        
        self.contentView.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.layer.masksToBounds = false
    }
}
