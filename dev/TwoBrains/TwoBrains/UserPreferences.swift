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

class UserPreferences: NSObject {
    public var circleSize: CGFloat  = 15.0
    public var circleSpeed: CGFloat = 4.0
    public var joystickSpeed: CGFloat = 7.0
    
    static let shared: UserPreferences = {
        let instance = UserPreferences()
        // setup code
        return instance
    }()

    private override init() {
        super.init()
        print("UserPreferences.init")
        
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

    
    func storeUserPreferences() {
        let userPrefrences = UserDefaults.standard
        
        userPrefrences.set(circleSize, forKey: circleSizeKey)
        userPrefrences.set(circleSpeed, forKey: circleSpeedKey)
        userPrefrences.set(joystickSpeed, forKey: joystickSpeedKey)
    }
}
