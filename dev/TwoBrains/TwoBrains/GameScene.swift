//
//  GameScene.swift
//  TwoBrains
//
//  Created by Matthew Homer on 12/22/24.
//

import SpriteKit
import GameController
import CoreHaptics

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
    private var circleLeftVelocity : CGPoint = .zero
    private var circleRightVelocity : CGPoint = .zero
    private var joystickMoveDistance: Float = 5.0
    private var randomMoveDistance: CGFloat = 4.0

    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
        self.circleLeftNode = self.childNode(withName: circleLeftName) as! SKShapeNode
        self.circleRightNode = self.childNode(withName: circleRightName) as! SKShapeNode
        self.textNode = self.childNode(withName: textNodeName) as! SKLabelNode
        gameController = GameController(scene: self)
    }
    
    func setupGame() {
        circleLeftVelocity = randomMovement()
        circleRightVelocity = randomMovement()
        lastUpdateTime = 0.0
        startTime = Date()
        secondsInterval = 0.0
        time = -1
    }
    
    func randomMovement() -> CGPoint {
        let randomdegree = Double.random(in: 0..<Double.pi*2)
        let formattedFloat = String(format: "%.2f", randomdegree)
        print("GameScene.randomMovement     randomdegree: \(formattedFloat) rads")
        let x: CGFloat = randomMoveDistance * sin(randomdegree)
        let y: CGFloat = randomMoveDistance * cos(randomdegree)
        return CGPoint(x: x, y: y)
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

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if pauseGame || !gameController.gameControllerIsConnected { return }

        if secondsInterval < currentTime.rounded(.down) {
            time += 1
            secondsInterval = currentTime
            updateEachSecond()
        }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        let xLeft = circleLeftVelocity.x * deltaTime
        let yLeft = circleLeftVelocity.y * deltaTime
        let circleLeftPoint = CGPoint(x:Double(circleLeftNode.position.x + xLeft), y: Double(circleLeftNode.position.y + yLeft))
        
        let xLeftSquared = circleLeftPoint.x * circleLeftPoint.x
        let yLeftSquared = circleLeftPoint.y * circleLeftPoint.y

        if xLeftSquared + yLeftSquared < outerCircleRadiusSquared {
            circleLeftNode.position = circleLeftPoint
        }
        else {
/*            let difference = sqrt(xLeftSquared + yLeftSquared - outerCircleRadiusSquared)
            let angle = atan2(circleLeftVelocity.y, circleLeftVelocity.x)
            
            let minusX = sin(angle) * difference
            let minusY = cos(angle) * difference
            let adjustedCirclePoint = CGPoint(x:Double(circleLeftPoint.x  - minusX), y: Double(circleLeftPoint.y - minusY))
   //         circleLeftNode.position = adjustedCirclePoint*/
            handleHitOuterEdge("circleLeftPoint")
        }
        
        let xRight = circleRightVelocity.x * deltaTime
        let yRight = circleRightVelocity.y * deltaTime
        let circleRightPoint = CGPoint(x:Double(circleRightNode.position.x + xRight), y: Double(circleRightNode.position.y + yRight))
        let xRightSquared = circleRightPoint.x * circleRightPoint.x
        let yRightSquared = circleRightPoint.y * circleRightPoint.y
        
        if xRightSquared + yRightSquared < outerCircleRadiusSquared {
            circleRightNode.position = circleRightPoint
        }
        else {
/*            let difference = sqrt(xRightSquared + yRightSquared - outerCircleRadiusSquared)
            let angle = atan2(circleRightVelocity.y, circleRightVelocity.x)
            
            let minusX = sin(angle) * difference
            let minusY = cos(angle) * difference
            let adjustedCirclePoint = CGPoint(x:Double(circleRightPoint.x  - minusX), y: Double(circleRightPoint.y - minusY))
     //       circleRightNode.position = adjustedCirclePoint*/
            handleHitOuterEdge("circleRightPoint")
        }

        if !pauseGame {
            gameController.pollInput(deltaTime: deltaTime)
        }
   }
}
