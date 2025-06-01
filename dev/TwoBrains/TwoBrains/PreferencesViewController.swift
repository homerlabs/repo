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

class PreferencesViewController: UIViewController
{
    @IBOutlet weak var joystickSpeedTextView: UITextField!
    @IBOutlet weak var ballSizeTextView: UITextField!
    @IBOutlet weak var ballSpeedTextView: UITextField!

    let userPreferences = UserPreferences.shared
    
    @IBAction func useDefualtsAction(sender: UIButton)
    {
        print("useDefualtsAction")
    }
    
    @IBAction func SaveAction(sender: UIButton)
    {
        print("SaveAction")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userPreferences.storeUserPreferences()
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
        ballSizeTextView.text = String.init(format: "%0.1f", userPreferences.circleSize)
        ballSpeedTextView.text = String.init(format: "%0.1f", userPreferences.circleSpeed)
        joystickSpeedTextView.text = String.init(format: "%0.1f", userPreferences.joystickSpeed)
            
        gameController.delegate = self
    }
    
    func increment() {
        if ballSizeTextView.isFocused {
            userPreferences.circleSize += 1.0
            ballSizeTextView.text = String.init(format: "%0.1f", userPreferences.circleSize)
        }
        else if ballSpeedTextView.isFocused {
            userPreferences.circleSpeed += 1.0
            ballSpeedTextView.text = String.init(format: "%0.1f", userPreferences.circleSpeed)
        }
        else if joystickSpeedTextView.isFocused {
            userPreferences.joystickSpeed += 1.0
            joystickSpeedTextView.text = String.init(format: "%0.1f", userPreferences.joystickSpeed)
        }
    }
    
    func decrement() {
        if ballSizeTextView.isFocused {
            userPreferences.circleSize -= 1.0
            ballSizeTextView.text = String.init(format: "%0.1f", userPreferences.circleSize)
        }
        else if ballSpeedTextView.isFocused {
            userPreferences.circleSpeed -= 1.0
            ballSpeedTextView.text = String.init(format: "%0.1f", userPreferences.circleSpeed)
        }
        else if joystickSpeedTextView.isFocused {
            userPreferences.joystickSpeed -= 1.0
            joystickSpeedTextView.text = String.init(format: "%0.1f", userPreferences.joystickSpeed)
        }
    }
}
