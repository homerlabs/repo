//
//  HLGameController.swift
//  HLPong
//
//  Created by Matthew Homer on 8/5/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import UIKit
import GameKit


protocol HLGameControllerProtocol {
    func buttonXPressed()
    func buttonYPressed()
    func buttonAPressed()
    func buttonBPressed()
    func updatePaddle(paddle: GCControllerDirectionPad)
}


class HLGameController: NSObject {

    public var gamepad: GCExtendedGamepad?
    
    var leftThumbstickX: CGFloat = 0.0
    var leftThumbstickY: CGFloat = 0.0
    var rightThumbstickX: CGFloat = 0.0
    var rightThumbstickY: CGFloat = 0.0
    
    var leftThumbstick: GCControllerDirectionPad!
    var rightThumbstick: GCControllerDirectionPad!
    
    var buttonX: GCControllerButtonInput!
    var buttonY: GCControllerButtonInput!
    var buttonA: GCControllerButtonInput!
    var buttonB: GCControllerButtonInput!
    
    var delegate: HLGameControllerProtocol!

    public convenience init(gamepad: GCExtendedGamepad, delegate: HLGameControllerProtocol) {
        self.init()
        self.delegate = delegate
        self.gamepad = gamepad
        assignGamepad(mode: 0)
    }


    func readPad(pad: GCControllerDirectionPad) {
    
        if pad == leftThumbstick   {
            leftThumbstickX = CGFloat(pad.xAxis.value)
            leftThumbstickY = CGFloat(pad.yAxis.value)
    //        print("readPad-  leftThumbstickX \(Int(leftThumbstickX*100))    leftThumbstickY \(Int(leftThumbstickY*100))")
        }
        else if pad == rightThumbstick   {
            rightThumbstickX = CGFloat(pad.xAxis.value)
            rightThumbstickY = CGFloat(pad.yAxis.value)
    //        print("readPad-  rightThumbstickX \(Int(rightThumbstickX*100))    rightThumbstickY \(Int(rightThumbstickY*100))")
        }
        else    {
             print("readPad-  ??")
       }
       
       delegate.updatePaddle( paddle: pad)
    }


    func assignGamepad(mode: Int) {
    
        print("assignGamepad: \(mode)")
        leftThumbstick = gamepad?.leftThumbstick
        rightThumbstick = gamepad?.rightThumbstick
        
        if mode == 0    {
            leftThumbstick.xAxis.valueChangedHandler = { _ in
                self.readPad(pad: self.leftThumbstick)
            }
            
            rightThumbstick.xAxis.valueChangedHandler = { _ in
                self.readPad(pad: self.rightThumbstick)
            }
            
            leftThumbstick.yAxis.valueChangedHandler = nil
            rightThumbstick.yAxis.valueChangedHandler = nil
        }
        
        else    {
            leftThumbstick.yAxis.valueChangedHandler = { _ in
                    self.readPad(pad: self.leftThumbstick)
            }
            
            rightThumbstick.yAxis.valueChangedHandler = { _ in
                    self.readPad(pad: self.rightThumbstick)
            }
            
            leftThumbstick.xAxis.valueChangedHandler = nil
            rightThumbstick.xAxis.valueChangedHandler = nil
        }
        
        buttonX = gamepad?.buttonX
        buttonX.pressedChangedHandler = { _ in
        //     print("buttonX: \(self.buttonX.isPressed)")
             if self.buttonX.isPressed      {   self.delegate.buttonXPressed()   }
        }
        
        buttonY = gamepad?.buttonY
        buttonY.pressedChangedHandler = { _ in
        //     print("buttonY: \(self.buttonY.isPressed)")
             if self.buttonY.isPressed      {   self.delegate.buttonYPressed()   }
        }
        
        buttonA = gamepad?.buttonA
        buttonA.pressedChangedHandler = { _ in
        //     print("buttonA: \(self.buttonA.isPressed)")
             if self.buttonA.isPressed      {   self.delegate.buttonAPressed()   }
        }
        
        buttonB = gamepad?.buttonB
        buttonB.pressedChangedHandler = { _ in
        //     print("buttonB: \(self.buttonB.isPressed)")
             if self.buttonB.isPressed      {   self.delegate.buttonBPressed()   }
        }
    }
}
