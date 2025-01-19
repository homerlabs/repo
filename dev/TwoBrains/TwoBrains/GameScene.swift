//
//  GameScene.swift
//  TwoBrains
//
//  Created by Matthew Homer on 12/22/24.
//

import SpriteKit
import GameController
import CoreHaptics


enum PhysicsCategory {
    static let none:        UInt32 = 0
    static let background:  UInt32 = 0b1
    static let player:      UInt32 = 0b10
}


class GameScene: SKScene {
    
    var secondsInterval: TimeInterval = 0
    var time = -1
    var startTime = Date()


    var gameController: GameController!
    var circleLeftNode = SKShapeNode()
    var circleRightNode = SKShapeNode()
    var textNode  = SKLabelNode()
    var lastUpdateTime  = 0.0
    
    var pauseGame: Bool = true
    private var randomVelocityL : CGPoint = .zero
    private var randomVelocityR : CGPoint = .zero
    private var moveDistanceJoystick: CGFloat = 7.0
    private var moveDistanceRandom: CGFloat = 5.0

    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
        physicsWorld.contactDelegate = self

        self.circleLeftNode = self.childNode(withName: circleLeftName) as! SKShapeNode
        self.circleRightNode = self.childNode(withName: circleRightName) as! SKShapeNode
        self.textNode = self.childNode(withName: textNodeName) as! SKLabelNode
        gameController = GameController(scene: self)
    }
    
    func setupGame() {
        randomVelocityL = randomMovement()
        randomVelocityR = randomMovement()
        lastUpdateTime = 0.0
        startTime = Date()
        secondsInterval = 0.0
        time = -1
        print("GameScene.setupGame: \(String(format: "LVelocity.x  %.2f   .y  %.2f", randomVelocityL.x, randomVelocityL.y))")
        print("GameScene.setupGame: \(String(format: "RVelocity.x  %.2f   .y  %.2f", randomVelocityR.x, randomVelocityR.y))")
    }
    
    func randomMovement() -> CGPoint {
        let randomdegree = Double.random(in: 0..<Double.pi*2)
        let y: CGFloat = moveDistanceRandom * sin(randomdegree)
        let x: CGFloat = moveDistanceRandom * cos(randomdegree)
        return CGPoint(x: x, y: y)
    }
    
    func updatePosition(position: CGPoint, randomVelocity: CGPoint, joystickVelocity: CGPoint) -> CGPoint {
        return CGPoint(x: position.x + randomVelocity.x + joystickVelocity.x, y: position.y + randomVelocity.y + joystickVelocity.y)
    }

    func handleHitOuterEdge(_ message: String) {
        let timeSinceStart = -startTime.timeIntervalSinceNow
        let formattedFloat = String(format: "%.1f", timeSinceStart)
        print("GameScene.handleHitOuterEdge   \(message)  timeSinceStart: \(formattedFloat)")
        textNode.text = "Elapsed Time: \(formattedFloat) Seconds"

        pauseGame = true
    }

    func updateEachSecond() {
        textNode.fontColor = textColor
        textNode.text = "Elapsed Time: \(time) Seconds"
//        print("Time:", time, terminator: "s\n")
    }
    
    func joystickVelocity(gameControllerPad: GCControllerDirectionPad?, moveDistance: CGFloat, deltaTime: TimeInterval) -> CGPoint {
        if let gamePad = gameControllerPad {
            //          print("gamePadLeft.xAxis.value: \(gamePadLeft.xAxis.value)    yAxis.value: \(gamePadLeft.yAxis.value)")
            let x = CGFloat(gamePad.xAxis.value) * moveDistanceJoystick * CGFloat(deltaTime)
            let y = CGFloat(gamePad.yAxis.value) * moveDistanceJoystick * CGFloat(deltaTime)
            return CGPoint(x: x, y: y)
        }
        else {
            print("joystickVelocity.gameControllerPad is nil")
            return .zero
        }
    }
    
    func adjustPositionForInBounds(position: CGPoint) -> CGPoint {
        var adjustedPosition = position
        let lengthToCenter = sqrt(position.x*position.x + position.y*position.y)
        
        if lengthToCenter > outerCircleRadius {
            let percentageReduction = outerCircleRadius / lengthToCenter
            adjustedPosition.x *= percentageReduction
            adjustedPosition.y *= percentageReduction
            handleHitOuterEdge("adjustPositionForInBounds")
        }

        return adjustedPosition
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if pauseGame || !gameController.gameControllerIsConnected {
            return
        }

        if secondsInterval < currentTime.rounded(.down) {
            time += 1
            secondsInterval = currentTime
            updateEachSecond()
        }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        let joystickVelocityL = joystickVelocity(gameControllerPad: gameController.gamePadLeft, moveDistance: moveDistanceJoystick, deltaTime: deltaTime)
        let joystickVelocityR = joystickVelocity(gameControllerPad: gameController.gamePadRight, moveDistance: moveDistanceJoystick, deltaTime: deltaTime)

        let adjustedRandomVelocityL = CGPoint(x: randomVelocityL.x * deltaTime, y: randomVelocityL.y * deltaTime)
        let adjustedRandomVelocityR = CGPoint(x: randomVelocityR.x * deltaTime, y: randomVelocityR.y * deltaTime)
        
        let positionL = updatePosition(position: circleLeftNode.position, randomVelocity: adjustedRandomVelocityL, joystickVelocity: joystickVelocityL)
        let positionR = updatePosition(position: circleRightNode.position, randomVelocity: adjustedRandomVelocityR, joystickVelocity: joystickVelocityR)
        
        circleLeftNode.position = adjustPositionForInBounds(position: positionL)
        circleRightNode.position = adjustPositionForInBounds(position: positionR)
   }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        pauseGame = true

        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Check collision bodies
 //       let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        print("didBegin  collision: \(String(describing: bodyA.node?.name)) \(String(describing: bodyB.node?.name))")
    }
}
