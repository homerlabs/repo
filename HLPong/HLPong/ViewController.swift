//
//  ViewController.swift
//  HLPong
//
//  Created by Matthew Homer on 8/4/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import GameKit
import UIKit

class ViewController: GCEventViewController, HLGameControllerProtocol {

    @IBOutlet weak var bottomPaddleView: UIView!
    @IBOutlet weak var leftPaddleView: UIView!
    @IBOutlet weak var rightPaddleView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    @IBOutlet weak var leftControlView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var missLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    let updateInterval: TimeInterval = 0.02
    
    var edgeOffsetX: CGFloat = 0.0
    var edgeOffsetY: CGFloat = 0.0
    let paddleLength: CGFloat = 101.0
    
    var totalCount = 0
    var missCount = 0
    var scoreCount = 0
    let terminalCount = 10
    var result = 0
    
    var gamePad: HLGameController?
    var gameMode = 0
    
    var updateTimer: Timer?
    let dotView = UIImageView(image: UIImage(named: "dot.png")!)
    
    var pong: HLPong!
    
    var soundId1: SystemSoundID?
    var soundId2: SystemSoundID?


    var playerIndex = GCControllerPlayerIndex.index1
    
    func incrementPlayerIndex() -> GCControllerPlayerIndex {
        switch playerIndex {
        case .index1:
            playerIndex = .index2
        case .index2:
            playerIndex = .index3
        case .index3:
            playerIndex = .index4
        default:
            playerIndex = .index1
        }
        return playerIndex
    }
    
//  protocol HLGameControllerProtocol
    func buttonXPressed()
    {
 //       print( "buttonXPressed" )
        if gameMode == 0    {   setupGame(mode: 1)    }
        else                {   setupGame(mode: 0)    }
    }

    func buttonYPressed()
    {
//        print( "buttonYPressed" )
        resetGame()
    }

    func buttonAPressed()
    {
 //       print( "buttonAPressed" )
        startTimer()
    }

    func buttonBPressed()
    {
//        print( "buttonBPressed" )
        stopTimer()
    }
    
    func updatePaddle(paddle: GCControllerDirectionPad)     {

        if gameMode == 0    {
            var delta: CGFloat = 0.0
            let leftX = Float(gamePad!.leftThumbstickX)
            let rightX = Float(gamePad!.rightThumbstickX)
            if abs(leftX) > abs(rightX)     {   delta = gamePad!.leftThumbstickX    }
            else                            {   delta = gamePad!.rightThumbstickX   }

            let controlCenterX = bottomControlView.frame.size.width / 2.0
            let xRange = (playView.frame.size.width - bottomPaddleView.frame.size.width) / 2.0
            let bottomX: CGFloat = controlCenterX + xRange * CGFloat(delta)

            //            print( "readInputs-  lValue: \(leftX)     rValue: \(rightX)     delta: \(delta)" )
            //            let delta = controlCenterX - 26

            let newBCenter = CGPoint(x: bottomX, y: bottomPaddleView.center.y)
            bottomPaddleView.center = newBCenter
        }
        else                {
            if paddle == gamePad!.leftThumbstick         {
                let yRange = (playView.frame.size.height - leftPaddleView.frame.size.height) / 2.0
                let controlCenterY = leftControlView.frame.size.height / 2.0
                let leftY: CGFloat = controlCenterY - yRange * gamePad!.leftThumbstickY
                
                let newLCenter = CGPoint(x: leftPaddleView.center.x, y: leftY)
        //          print( "readInputs-  newLCenter: \(newLCenter)" )
                leftPaddleView.center = newLCenter
            }
            else if paddle == gamePad!.rightThumbstick   {
                let yRange = (playView.frame.size.height - leftPaddleView.frame.size.height) / 2.0
                let controlCenterY = leftControlView.frame.size.height / 2.0
                let rightY: CGFloat = controlCenterY - yRange * gamePad!.rightThumbstickY
                
                let newRCenter = CGPoint(x: rightPaddleView.center.x, y: rightY)
        //          print( "readInputs-  newLCenter: \(newLCenter)" )
                rightPaddleView.center = newRCenter
            }
            else    {
                assert( false )
            }
        }
    }

    func createSystemSoundID(name: String) -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), name as CFString, "aiff" as CFString, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
    
    func setupGame(mode: Int)    {
        
        var imageFilename = ""
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        gameMode = mode

        if gameMode == 0    {
            imageFilename = "pong.png"
            xOffset = 2.0
            yOffset = 15.0
    
            edgeOffsetY = 50.0
            edgeOffsetX = 25.0
            
            rightPaddleView.isHidden = true
            leftPaddleView.isHidden = true
            bottomPaddleView.isHidden = false
        }
        else    {
            imageFilename = "pong2.png"
            xOffset = 20.0
            yOffset = 2.0
    
            edgeOffsetX = 50.0
            edgeOffsetY = 25.0
            
            rightPaddleView.isHidden = false
            leftPaddleView.isHidden = false
            bottomPaddleView.isHidden = true
        }
        
        gamePad?.assignGamepad(mode: gameMode)

        pong?.imageView.removeFromSuperview()
        
        pong = HLPong(imageName: imageFilename, xVelocity: xOffset, yVelocity: yOffset)
        pong.imageView.center = playView.center
        playView.addSubview(pong.imageView)
        
        resetGame()
//        startTimer()
    }
    
    
    func resetGame()    {
        stopTimer()
        
        pong.imageView.center = playView.center
        
        totalCount = 0
        missCount = 0
        scoreCount = 0
        result = 0
        
        updateLabels()
    }
    
    
    func updateLabels()
    {
        totalLabel.text = "Total: \(totalCount)"
        scoreLabel.text = "Tally: \(scoreCount)"
        missLabel.text = "Misses: \(missCount)"
        resultLabel.text = "Score: \(result)"
    }


    func stopGame() {
        stopTimer()
        result = (scoreCount + 75 * missCount) / totalCount
        updateLabels()
    }


    func advanceToken() {
    
        if gameMode == 0    {
            if pong.imageView.center.y + edgeOffsetY > playView.frame.height     {   //  at the bottom of field
    //            print( "lPaddleView.center.x: \(lPaddleView.center.x)    pongView.center.x: \(pongView.center.x)" )
                totalCount += 1
                let diff = abs(bottomPaddleView.center.x - pong.imageView.center.x)
                
                if  diff <= 50.0    {
                    if  diff <= 25.0    {   AudioServicesPlaySystemSound(soundId2!) }
                    else                {   AudioServicesPlaySystemSound(soundId1!) }
                    
                    scoreCount += Int(diff)
                }
                else    {   missCount += 1  }
                
                pong.velocityY = -pong.velocityY
                
                if totalCount >= terminalCount      {   stopGame()      }
            }
            
            else if pong.imageView.center.y < edgeOffsetY            {   //  at the top of field
                pong.velocityY = -pong.velocityY
            }
            
            if pong.imageView.center.x + edgeOffsetX > playView.frame.width || pong.imageView.center.x < edgeOffsetX     {
                pong.velocityX = -pong.velocityX
            }
        }
        
        else    {
            if pong.imageView.center.y < edgeOffsetY || pong.imageView.center.y + edgeOffsetY > playView.frame.height     {   //  at the top or bottom of field
                pong.velocityY = -pong.velocityY
            }
            
            if pong.imageView.center.x + edgeOffsetX > playView.frame.width     {       //  at the right side of field
                totalCount += 1
                let diff = abs(rightPaddleView.center.y - pong.imageView.center.y)
                if  diff <= 50.0    {
                    if  diff <= 25.0    {   AudioServicesPlaySystemSound(soundId2!) }
                    else                {   AudioServicesPlaySystemSound(soundId1!) }
                    
                    scoreCount += Int(diff)
                }
                else    {   missCount += 1  }

                pong.velocityX = -pong.velocityX
            }
            
            else if pong.imageView.center.x < edgeOffsetX           {       //  at the left side of field
                totalCount += 1
                let diff = abs(leftPaddleView.center.y - pong.imageView.center.y)
                if  diff <= 50.0    {
                    if  diff <= 25.0    {   AudioServicesPlaySystemSound(soundId2!) }
                    else                {   AudioServicesPlaySystemSound(soundId1!) }
                    
                    scoreCount += Int(diff)
                }
                else    {   missCount += 1  }

                pong.velocityX = -pong.velocityX
            }
            
            if totalCount >= terminalCount      {   stopGame()      }
        }
        
/*        var dotCenter = dotView.center
        dotCenter.x = pongView.center.x
        dotView.center = dotCenter  */
        
        var newCenter = pong.imageView.center
        newCenter.x += pong.velocityX
        newCenter.y += pong.velocityY
        pong.imageView.center = newCenter
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startWatchingForControllers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWatchingForControllers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        soundId1 = createSystemSoundID( name: "Frog" )
        soundId2 = createSystemSoundID( name: "Glass" )
        
        setupGame(mode: 0)

        var paddleFrame = bottomPaddleView.frame
        paddleFrame.size.width = paddleLength
        bottomPaddleView.frame = paddleFrame
       
        self.controllerUserInteractionEnabled = true
 //       print( "controllerUserInteractionEnabled: \(self.controllerUserInteractionEnabled)" )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {

        for item in presses {
            if item.type == .menu    {
      //          print( "pressesBegan-  .menu" )
                if updateTimer == nil       {   startTimer()    }
                else                        {   stopTimer()     }
            }
/*            else    {
                print( "pressesBegan-  item: \(item)" )
            }   */
        }
    }
}


extension ViewController { // controller detection
    func startWatchingForControllers() {
        let ctr = NotificationCenter.default
        ctr.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.add(ctrl)
            }
        }
        
        ctr.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.remove(ctrl)
            }
        }
        
        GCController.startWirelessControllerDiscovery(completionHandler: {})
    }

    func stopWatchingForControllers() {
        let ctr = NotificationCenter.default
        ctr.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        ctr.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)
        GCController.stopWirelessControllerDiscovery()
    }
    
    func startTimer()   {
        if updateTimer == nil   {
            updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: {_ in
                self.advanceToken()
            })
        }
    }
    
    func stopTimer()     {
        if updateTimer != nil {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }

    func add(_ controller: GCController) {
        let name = String(describing:controller.vendorName)
        if let gamepadTemp = controller.extendedGamepad {
            if gamePad == nil     {
                print("connected extended \(name)")
                controller.playerIndex = incrementPlayerIndex()
                gamePad = HLGameController(gamepad: gamepadTemp, delegate: self)
            
//                startTimer()
            }
            else    {   print("ignored extended \(name)")   }
        }
        else if controller.microGamepad != nil  {   print("found micro \(name)")    }
        else                                    {   print("Huh? \(name)")           }
    }

    func remove(_ controller: GCController) {
        let name = String(describing:controller.vendorName)
        print("removed \(name)")
        stopTimer()
        gamePad = nil
    }
}
