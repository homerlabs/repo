//
//  GameViewController.swift
//  TwoBrains
//
//  Created by Matthew Homer on 12/7/24.
//

import UIKit
import SpriteKit
import GameplayKit
import GameController

public let outerCircleRadiusSquared: CGFloat = 250000.0 //  used for trig calcs
public let outerCircleRadius: CGFloat = 500.0

let circleRightName = "circleRightName"
let circleLeftName = "circleLeftName"
public let textNodeName = "textNodeName"

public let textColor: UIColor = .white

class GameViewController: GCEventViewController {
    let innerCircleRadius: CGFloat = 18.0
    let movingCircleRadius: CGFloat = 15.0

    var gameController: GameController?
    var scene = SKScene(size: .zero)

    var gameView: SKView? {
        return view as? SKView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            //  create scene and its nodes
            let scene = GameScene(size: view.bounds.size)
            scene.backgroundColor = .black
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Set the scene coordinates (0, 0) to the center of the screen.
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            let outerCircle = SKShapeNode(circleOfRadius: outerCircleRadius)
            outerCircle.name = "outerCircle"
            outerCircle.lineWidth = 5.0
            outerCircle.strokeColor = .white

            let innerCircle = SKShapeNode(circleOfRadius: innerCircleRadius)
            innerCircle.name = "innerCircle"
            innerCircle.lineWidth = 2.0
            innerCircle.strokeColor = .white

            let circleRight = SKShapeNode(circleOfRadius: movingCircleRadius)
      //      circleRight.alpha = 0.5
            circleRight.fillColor = .red
            circleRight.name = circleRightName
            circleRight.position = CGPoint(x: 0.0, y: 0.0)

            let circleLeft = SKShapeNode(circleOfRadius: movingCircleRadius)
            circleLeft.fillColor = .magenta
            circleLeft.name = circleLeftName
            circleLeft.position = CGPoint(x: 0.0, y: 0.0)

            let textNode = SKLabelNode(fontNamed: "Helvetica")
    //        let textNode = SKLabelNode(fontNamed: "Arial")
            textNode.name = textNodeName
            textNode.fontSize = 24.0
            textNode.horizontalAlignmentMode = .center
            textNode.fontColor = textColor
            textNode.text = "Unsure"
            textNode.position = CGPoint(x: 0.0, y: 450.0)

            // Add the circles to the scene.
            scene.addChild(circleRight)
            scene.addChild(circleLeft)
            scene.addChild(textNode)
            
            scene.addChild(innerCircle)
            scene.addChild(outerCircle)
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
