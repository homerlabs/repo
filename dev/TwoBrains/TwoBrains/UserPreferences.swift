//
//  UserPreferences.swift
//  TwoBrains
//
//  Created by Matthew Homer on 3/28/25.
//

import Foundation

let circleSizeKey   = "circleSizeKey"
let circleSpeedKey  = "circleSpeedKey"
let joystickSpeedKey = "joystickSpeedKey"

let defaultCircleSize: CGFloat = 10.0
let defaultCircleSpeed: CGFloat = 4.0
let defaultJoystickSpeed: CGFloat = 7.0

class UserPreferences: NSObject {
    public var circleSize: CGFloat  = defaultCircleSize
    public var circleSpeed: CGFloat = defaultCircleSpeed
    public var joystickSpeed: CGFloat = defaultJoystickSpeed
    
    static let shared: UserPreferences = {
        let instance = UserPreferences()
        // setup code
        return instance
    }()

    private override init() {
        super.init()
        print("UserPreferences.init-  SINGLETON")
        
        let userPrefrences = UserDefaults.standard
        
        let circleSize = userPrefrences.float(forKey: circleSizeKey)
        if circleSize > 0 {
            self.circleSize = CGFloat(circleSize)
        }
        
        let circleSpeed = userPrefrences.float(forKey: circleSpeedKey)
        if circleSpeed > 0 {
            self.circleSpeed = CGFloat(circleSpeed)
        }
        
        let joystickSpeed = userPrefrences.float(forKey: joystickSpeedKey)
        if joystickSpeed > 0 {
            self.joystickSpeed = CGFloat(joystickSpeed)
        }
    }

    
    func resetUserPreferences() {
        print("UserPreferences.resetUserPreferences")

        let userPrefrences = UserDefaults.standard
        
        circleSize = defaultCircleSize
        circleSpeed = defaultCircleSize
        joystickSpeed = defaultJoystickSpeed

        userPrefrences.set(circleSize, forKey: circleSizeKey)
        userPrefrences.set(circleSpeed, forKey: circleSpeedKey)
        userPrefrences.set(joystickSpeed, forKey: joystickSpeedKey)
    }
    
    func storeUserPreferences() {
        let userPrefrences = UserDefaults.standard
        
        userPrefrences.set(circleSize, forKey: circleSizeKey)
        userPrefrences.set(circleSpeed, forKey: circleSpeedKey)
        userPrefrences.set(joystickSpeed, forKey: joystickSpeedKey)
    }
}
