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

class PreferencesViewController: UIViewController, TBGameControllerProtocol
{
    @IBOutlet weak var joystickSpeedTextView: UITextField!
    @IBOutlet weak var ballSizeTextView: UITextField!
    @IBOutlet weak var ballSpeedTextView: UITextField!
    @IBOutlet weak var useDefaultsButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    let userPreferences = UserPreferences.shared
    
    @IBAction func useDefualtsAction(sender: UIButton)
    {
        print("useDefualtsAction")
        userPreferences.resetUserPreferences()
    }
    
    @IBAction func SaveAction(sender: UIButton)
    {
        print("SaveAction")
        userPreferences.storeUserPreferences()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gameController.delegate = self as PreferencesViewController
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
    
    //  TBGameControllerProtocol
    func buttonA_X(_ value: Bool) {
        print("PreferencesViewController.buttonA_X:  \(value)")
        if ballSizeTextView.isFocused {
        }
        
        userPreferences.circleSize = defaultCircleSize
        userPreferences.circleSpeed = defaultCircleSpeed
        userPreferences.joystickSpeed = defaultJoystickSpeed
    }
    func buttonB_Circle(_ value: Bool) {
        print("PreferencesViewController.buttonB_Circle:  \(value)")
    }
    func buttonX_Square(_ value: Bool) {
        print("PreferencesViewController.buttonX_Square:  \(value)")
    }
    func buttonY_Triangle(_ value: Bool) {
        print("PreferencesViewController.buttonY_Triangle:  \(value)")
    }
}
