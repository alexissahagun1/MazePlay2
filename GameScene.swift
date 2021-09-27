//
//  GameScene.swift
//  MazePlay
//
//  Created by gdaalumno on 20/09/21.
//

import SpriteKit
import CoreMotion


enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case hole = 8
    case finish = 16
    
}


class GameScene: SKScene {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager?
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        
        addChild(background)
        
        createPlayer()
        loadLevel()
        
        
        physicsWorld.gravity = .zero
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{return}
        let location = touch.location(in: self)
        
        lastTouchPosition = location
        print("began touched...")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{return}
        let location = touch.location(in: self)
        
        lastTouchPosition = location
        print("being touches moved...")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
        print("touched ended")
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let difference = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: difference.x / 100, dy: difference.y / 100)
            
            print("being updated")
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }


    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2.1)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.hole.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "maze1", withExtension: "txt") else { fatalError("Can't find maze1.txt in app bundle")}
        
        guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Can't find maze1.txt in app bundle")}
        
        let lines = levelString.components(separatedBy: "\n")
        
        for(row,line) in lines.reversed().enumerated() {
            for(column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if(letter == "w") {
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    
                    addChild(node)
                } else if letter == "h" {
                    let node = SKSpriteNode(imageNamed: "hole")
                    node.name = "hole"
                    node.position = position
                    
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hole.rawValue
                    
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                    
                    
                    
                }
                else if letter == "s" {
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    
                    
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hole.rawValue
                    
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    
                    node.physicsBody?.collisionBitMask = 0
                    
                    node.position = position
                    
                    addChild(node)
                    
                
                }
                else if letter == "f" {
                    
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hole.rawValue
                    
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    
                    node.physicsBody?.collisionBitMask = 0
                    
                    node.position = position
                    
                    addChild(node)
                    
                
                }
                else if letter == " " {
                
                }
                else {
                    fatalError("Unknown character in maze1.txt: \(letter)")
                }

            }
        }
    }
}

