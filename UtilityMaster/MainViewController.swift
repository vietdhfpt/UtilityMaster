//
//  MainViewController.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/15/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import UIKit

enum UtilitySegmentIndex: Int {
    case converter = 0
    case calculator = 1
    case timer = 2
    case stopwatch = 3
}

enum UtilitySelectedSegmentNofification: String {
    case converter = "SelectedSegmentConverter"
    case calculator = "SelectedSegmentCalculator"
    case timer = "SelectedSegmentTimer"
    case stopwatch = "SelectedSegmentStopwatch"
}

class MainViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var converterContainerView: UIView!
    @IBOutlet weak var calculatorContainerView: UIView!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var stopwatchContainerView: UIView!
    var utilityToolViews = [UIView]()
    var lastSelectedTool: UIView!
    var selectedTool: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.utilityToolViews = [converterContainerView, calculatorContainerView, timerContainerView, stopwatchContainerView]
        self.initSubviews()
        self.title = "Utility Tool"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let startWithSegmentIndex = AppSettings.settingForKey(kAppSettingsPilotUtilityDefaultSegmentIndex) as? Int {
            self.showTool(selectedSegmentIndex: startWithSegmentIndex)
            self.segmentedControl.selectedSegmentIndex = startWithSegmentIndex
        } else {
            AppSettings.setSetting(UtilitySegmentIndex.calculator.rawValue, forKey: kAppSettingsPilotUtilityDefaultSegmentIndex)
            self.showTool(selectedSegmentIndex: UtilitySegmentIndex.calculator.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init UI
    func initSubviews() {
        self.iniUtilityToolTypeSegmentedControl()
        self.initConverterContainerView()
        self.initCalculatorContainerView()
        self.initTimerContainerView()
        self.initStopwatchContainerView()
    }
    
    func iniUtilityToolTypeSegmentedControl() {
        let attributes = [NSForegroundColorAttributeName : UIColor(white: 0xC1C1C1, alpha: 1),
                          NSFontAttributeName : UIFont.systemFont(ofSize: 13)];
        let attributesSelected = [NSForegroundColorAttributeName : UIColor(white: 0xFFFFFF, alpha: 1),
                                  NSFontAttributeName : UIFont.systemFont(ofSize: 13)];
        self.segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        self.segmentedControl.setTitleTextAttributes(attributesSelected, for: .selected)
    }
    
    func initConverterContainerView() {
        self.converterContainerView.alpha = 0
    }
    
    func initCalculatorContainerView() {
        self.calculatorContainerView.alpha = 0
    }
    
    func initTimerContainerView() {
        self.timerContainerView.alpha = 0
    }
    
    func initStopwatchContainerView() {
        self.stopwatchContainerView.alpha = 0
    }
    
    // MARK: - Segmentd control
    @IBAction func utilityTypeSegmentChanged(_ sender: UISegmentedControl) {
        self.showTool(selectedSegmentIndex: sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case UtilitySegmentIndex.converter.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name(UtilitySelectedSegmentNofification.converter.rawValue), object: nil)
        case UtilitySegmentIndex.calculator.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name(UtilitySelectedSegmentNofification.calculator.rawValue), object: nil)
        case UtilitySegmentIndex.timer.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name(UtilitySelectedSegmentNofification.timer.rawValue), object: nil)
        case UtilitySegmentIndex.stopwatch.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name(UtilitySelectedSegmentNofification.stopwatch.rawValue), object: nil)
        default:
            break
        }
    }
    
    //MARK: - Action
    func showTool(selectedSegmentIndex: Int) {
        if let lastSelectedSegmentIndex = AppSettings.settingForKey(kAppSettingsPilotUtilityDefaultSegmentIndex) as? Int {
            self.lastSelectedTool = self.utilityToolViews[lastSelectedSegmentIndex]
            self.selectedTool = self.utilityToolViews[selectedSegmentIndex]
            self.segmentedControl.isEnabled = false
            self.lastSelectedTool.alpha = 0
            self.selectedTool.alpha = 1
            self.segmentedControl.isEnabled = true
            AppSettings.setSetting(selectedSegmentIndex, forKey: kAppSettingsPilotUtilityDefaultSegmentIndex)
        }
    }
}
