//
//  PreferencesViewController.swift
//  TwoBrains
//
//  Created by Matthew Homer on 3/11/25.
//

import UIKit
import SpriteKit
import GameplayKit
import GameController

class PreferencesViewController: UIViewController {
    @IBOutlet weak var joystickSpeedTextView: UITextField!
    @IBOutlet weak var ballSizeTextView: UITextField!
    @IBOutlet weak var ballSpeedTextView: UITextField!
    let userPreferences = UserPreferences()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ballSizeTextView.text = String.init(format: "%0.1f", userPreferences.circleSize)
        ballSpeedTextView.text = String.init(format: "%0.1f", userPreferences.circleSpeed)
        joystickSpeedTextView.text = String.init(format: "%0.1f", userPreferences.joystickSpeed)
    }
}
