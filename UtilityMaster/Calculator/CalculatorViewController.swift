//
//  CalculatorViewController.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/15/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, CalculatorKeypadDelegate {

    @IBOutlet weak var keypadHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var formulaTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var equationLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.equationLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            //Portrait
            keypadHeightConstraint.constant = 420
            resultsTopConstraint.constant = 102.0
            formulaTopConstraint.constant = 24.0
        }
        else {
            //Landscape
            keypadHeightConstraint.constant = 200
            resultsTopConstraint.constant = 5.0
            formulaTopConstraint.constant = 10.0
        }
        
        for childVC in self.childViewControllers {
            if childVC.isKind(of: CalculatorKeypad.classForCoder())
            {
                let keyPadVC = childVC as? CalculatorKeypad
                keyPadVC?.delegate = self
            }
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if self.isViewLoaded{
            if size.width > size.height {
                //Landscape
                keypadHeightConstraint.constant = 200
                resultsTopConstraint.constant = 5.0
                formulaTopConstraint.constant = 10.0
            } else {
                //Portrait
                keypadHeightConstraint.constant = 420
                resultsTopConstraint.constant = 102.0
                formulaTopConstraint.constant = 24.0
            }
        }
    }
    
    //MARK: - KeyPad Delegates
    func updateCalculatorLabels(withEquation eqString: String, andResult resultsString : String) {
        self.equationLabel.text = eqString
        self.resultsLabel.text = resultsString
    }
}
