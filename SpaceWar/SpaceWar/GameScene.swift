//
//  GameScene.swift
//  SpaceWar
//
//  Created by Martin on 30.06.2020.
//  Copyright © 2020 Martin. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Variables
    let spaceShipCategory : UInt32 = 0x1 << 0
    let asteroidCategory : UInt32 = 0x1 << 1
    
    var spaceShip : SKSpriteNode!
    var background : SKSpriteNode!
    
    var score = 0
    var scoreLabel : SKLabelNode!
    var asteroidLayer : SKNode!
    var starsLayer : SKNode!
    var gameIsPause : Bool = false
    var spaceShipLayer: SKNode!
    var musicPlayer : AVAudioPlayer!
    
    var soundOn = true
    var musicOn = true
    //MARK: - Function
    
    func musicOnOff(){
        if musicOn {
            musicPlayer.play()
        }else {
            musicPlayer.stop()
        }
    }
    
    func pauseTheGame(){
        gameIsPause = true
        self.asteroidLayer.isPaused = true
        physicsWorld.speed = 0
        starsLayer.isPaused = true
        
        musicOnOff()
    }
    
    func unpauseTheGame(){
        gameIsPause = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false
        
        musicOnOff()
        
    }
    
    func resetTheGame(){
        score = 0
        scoreLabel.text = "Score \(score)"
        
        gameIsPause = false
        self.asteroidLayer.isPaused = false
        starsLayer.isPaused = false

        physicsWorld.speed = 1
    }
    
    func pauseButtonPress(sender: UIButton){
        if !gameIsPause {
            pauseTheGame()
        }else {
            unpauseTheGame()
        }
    }
    
    override func didMove(to view: SKView) {
        scene?.size = UIScreen.main.bounds.size
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        let width = UIScreen.main.bounds.width
        let heigth = UIScreen.main.bounds.height
        
        background = SKSpriteNode(imageNamed: "spaceBackround.jpg")
        background.size = CGSize(width: width + 50, height: heigth + 50)
        addChild(background)
        //stars
        
        let starPath = Bundle.main.path(forResource: "stars", ofType:"sks")
        let starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starPath!) as? SKEmitterNode
        starsEmitter?.zPosition = 1
        starsEmitter?.position = CGPoint(x: frame.midX, y: frame.height)
        starsEmitter?.particlePositionRange.dx = frame.width
        starsEmitter?.advanceSimulationTime(10)
       
        
        starsLayer = SKNode()
        starsLayer.zPosition = 1
        addChild(starsLayer)
        starsLayer.addChild(starsEmitter!)
        
        
        //ship
        spaceShip = SKSpriteNode(imageNamed: "spaceShip2.png")
        spaceShip.xScale = 0.7
        spaceShip.yScale = 0.7
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        //spaceShip.position = CGPoint(x: 100, y: 100)
        
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        let colorAction1 = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)

        let  colorSqueneAnimation = SKAction.sequence([colorAction1,colorAction2])
        let colorActionRepeat = SKAction.repeatForever(colorSqueneAnimation)
        spaceShip.run(colorActionRepeat)
        
        //addChild(spaceShip)
        //Створюємо шар для корабля
        spaceShipLayer = SKNode()
        spaceShipLayer.addChild(spaceShip)
        spaceShipLayer.zPosition = 3
        spaceShip.zPosition = 1
        spaceShipLayer.position = CGPoint(x: frame.midX, y: frame.height/4)
        addChild(spaceShipLayer)
        
        //create fire
        let firePath = Bundle.main.path(forResource: "fire", ofType: "sks")
        let fireEmmiter = NSKeyedUnarchiver.unarchiveObject(withFile: firePath!) as? SKEmitterNode
        fireEmmiter?.zPosition = 0
        fireEmmiter?.position.y = -40
        fireEmmiter?.targetNode = self
        spaceShipLayer.addChild(fireEmmiter!)
        
        //generation asteroid
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.addChild(asteroid)
            asteroid.zPosition = 2
        }
        let asteroidPerSecond : Double = 1
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidPerSecond , withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate,asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        self.asteroidLayer.run(asteroidRunAction)
        
        //create score label
        scoreLabel = SKLabelNode(text: "Score \(score)")
        scoreLabel.position  = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 250)
        addChild(scoreLabel)
        
        // setting node position
        background.zPosition = 0
        //spaceShip.zPosition = 1
        scoreLabel.zPosition = 3
        
        playMusic()
    }
    
    func playMusic(){
        if let musicPath = Bundle.main.url(forResource: "Background_music", withExtension: "mp3") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicPath, fileTypeHint: nil)
            musicOnOff()
        }
        musicPlayer.numberOfLoops = -1
        musicPlayer.volume = 0.2
    }
        
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touchs
        if !gameIsPause {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                print(touchLocation)
                let distance = distanceCalc(a: spaceShip.position, b: touchLocation)
                let speed : CGFloat = 500
                let time = timeToTravelDistance(distance: distance, speed: speed)
                let moveAction = SKAction.move(to: touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                spaceShipLayer.run(moveAction)
                
                let bgMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y / 100), duration: time)
                background.run(bgMoveAction)
            }
        }
    }
    
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y))
    }
    
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval{
        let time = distance / speed
        return TimeInterval(time)
    }
    
    func createAsteroid() -> SKSpriteNode {
        let asteroid = SKSpriteNode(imageNamed: "asteroid.pgn")
        let randomScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 5)) / 10
        
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale
        
        asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6))
        asteroid.position.y = frame.size.height + asteroid.size.height
        asteroid.name = "asteroid"
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: (asteroid.size))
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        let asteroidSpeedX = 100.0
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * CGFloat(asteroidSpeedX)
        
        return asteroid
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func didSimulatePhysics() {
        let hightScreen = UIScreen.main.bounds.height
        enumerateChildNodes(withName: "asteroid") { (asteroid, stop) in
            
            if asteroid.position.y < -hightScreen {
               
                asteroid.removeFromParent()
                print("Score func work")
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == spaceShipCategory{
            self.score = 0
            self.scoreLabel.text = "Score \(self.score)"
        }
        
        let hitSoundAction = SKAction.playSoundFileNamed("zvuk_udara", waitForCompletion: false)
        run(hitSoundAction)
    }
    
  
}
