//
//  GameController.swift
//  TwoBrain
//
//  Created by Matthew Homer on 11/29/24.
//

import GameController
import SpriteKit
import CoreHaptics
import GameplayKit
//import os

class GameController: NSObject
{
    // Game Controller Properties
    public var currentViewController: UIViewController?
    public var gameControllerIsConnected = false
    public var gamePadLeft: GCControllerDirectionPad?
    public var gamePadRight: GCControllerDirectionPad?

    private var gameScene: GameScene
    
    private var movePointLeft: CGPoint = .zero
    private var movePointRight: CGPoint = .zero
    
    private var joystickMoveDistance: Float = 7.0
    private var randomMoveDistance: CGFloat = 5.0
    
    private var pauseGame = false
    
    func controllerButtonMenu(_ value: Bool) {
        if !value {
            if currentViewController == nil {
                currentViewController = gameScene.view?.window?.rootViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Settings")
                currentViewController!.present(vc, animated: true)
            }
            else {
                currentViewController!.dismiss(animated: true)
                currentViewController = nil
            }
        }
    }
    
    func controllerLeftTrigger(_ value: Bool) {
        if value {
            gameScene.pauseGame = !gameScene.pauseGame
            gameScene.lastUpdateTime = 0
        }
    }
    
    func controllerRightTrigger(_ value: Bool) {
        if value {
            gameScene.pauseGame = true
            
            if gameControllerIsConnected {
                gameScene.textNode.text = "Elasped Time: 0 Seconds"
                gameScene.textNode.fontColor = textColor
            }
            else {
                gameScene.textNode.fontColor = .red
                gameScene.textNode.text = "No Game Controller Connected"
            }
            
            for node in gameScene.children {
                
                //  move targets to the center
                if node.name == circleLeftName {
                    let moveTo = SKAction.move(to: CGPointZero, duration: 0.15)
                    node.run(moveTo)
                }
                
                else if node.name == circleRightName {
                    let moveTo = SKAction.move(to: CGPointZero, duration: 0.15)
                    node.run(moveTo)
                }
            }
        }
        else {
            gameScene.pauseGame = false
            gameScene.setupGame()
        }
    }
    
    func setupGameController() {
        print("GameController.setupGameController")
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidConnect),
            name: NSNotification.Name.GCControllerDidBecomeCurrent, object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidStopBeingCurrent, object: nil)
        
        guard let controller = GCController.controllers().first else {
            //            print("GameController.setupGameController-->  No Game Controller")
            return
        }
        registerGameController(controller)
    }
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
        unregisterGameController()
        print("GameController.handleControllerDidConnect")
        
        registerGameController(gameController)
        HapticUtility.initHapticsFor(controller: gameController)
        
        //        self.overlay?.showHints()
    }
    
    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
        unregisterGameController()
        print("GameController.handleControllerDidDisconnect")
        
        guard let gameController = notification.object as? GCController else {
            return
        }
        
        HapticUtility.deinitHapticsFor(controller: gameController)
    }
    
    func registerGameController(_ gameController: GCController) {
        
        //        print("GameController.registerGameController")
        var buttonA: GCControllerButtonInput?
        var buttonB: GCControllerButtonInput?
        var leftTrigger: GCControllerButtonInput?
        var rightTrigger: GCControllerButtonInput?
        var buttonMenu: GCControllerButtonInput?

        weak var weakController = self
        
        if let gamepad = gameController.extendedGamepad {
            self.gamePadLeft = gamepad.leftThumbstick
            self.gamePadRight = gamepad.rightThumbstick
            buttonA = gamepad.buttonA
            buttonB = gamepad.buttonB
            buttonMenu = gamepad.buttonMenu
            leftTrigger = gamepad.leftTrigger
            rightTrigger = gamepad.rightTrigger
        } else if let gamepad = gameController.microGamepad {
            self.gamePadLeft = gamepad.dpad
            buttonA = gamepad.buttonA
            buttonB = gamepad.buttonX
        }
        
        buttonMenu?.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else {
                return
            }
            strongController.controllerButtonMenu(pressed)
        }
        
        buttonA?.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else {
                return
            }
            strongController.controllerLeftTrigger(pressed)
        }

        buttonB?.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else {
                return
            }
            strongController.controllerRightTrigger(pressed)
        }
        
        leftTrigger?.pressedChangedHandler = buttonA?.valueChangedHandler
        rightTrigger?.pressedChangedHandler = buttonB?.valueChangedHandler
        
        if let venderName = gameController.vendorName {
  //          print("venderName: \(venderName)")

            if venderName.hasPrefix("DUALSHOCK 4") || venderName.hasPrefix("DualSense Wireless Controller") {
                gameScene.textNode.fontColor = textColor
                gameScene.textNode.text = "Ready To Start"
                gameControllerIsConnected = true
            }
            else {
                gameScene.textNode.fontColor = .red
                gameScene.textNode.text = "No Game Controller"
                gameControllerIsConnected = false
            }
        }
    }
    
    func unregisterGameController() {
        //       print("GameController.unregisterGameController")
        gamePadLeft = nil
        gamePadRight = nil
        gameControllerIsConnected = false
    }
    
    func randomMovement() -> CGPoint {
        let randomdegree = Double.random(in: 0..<Double.pi*2)
        let y: CGFloat = randomMoveDistance * sin(randomdegree)
        let x: CGFloat = randomMoveDistance * cos(randomdegree)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Init
    init(scene: GameScene) {
        self.gameScene = scene
        super.init()

        setupGameController()
    }
}
