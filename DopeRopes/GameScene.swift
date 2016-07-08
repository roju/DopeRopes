//
//  GameScene.swift
//  DopeRopes
//
//  Created by Ross Justin on 7/5/16.
//  Copyright (c) 2016 Ross, Yulia. All rights reserved.
//

import SpriteKit
enum GameState {
    case pause, playing, gameOver
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    var hero: SKSpriteNode!
    var sinceTouch: CFTimeInterval = 2
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let firstRopePosition = CGPoint(x: 400,y:120)
    var ropePinJoint: SKPhysicsJointPin?
    var ground: SKSpriteNode!
    var arrayOfRopes = [Rope]()
    var sinceDeletion: CFTimeInterval = 0
    var previousRopeIndex = 0
    var pauseSquare: MSButtonNode!
    var scoreLabel: SKLabelNode!
    var gameOverSquare: SKSpriteNode!
    var highScoreCount: SKLabelNode!
    var yourScoreCount: SKLabelNode!
    var restartSquare: MSButtonNode!
    var state: GameState = .playing
    var score = 0
    var resumeSquare: MSButtonNode!
    
    var ropeSpacing = 260
    
    var hangingOnRope = false
    
    override func didMoveToView(view: SKView) {
      
        pauseSquare = childNodeWithName("//pauseSquare") as! MSButtonNode
        ground = childNodeWithName("//ground") as! SKSpriteNode
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
        gameOverSquare = childNodeWithName("//gameOverSquare") as! SKSpriteNode
        gameOverSquare.hidden = true
        highScoreCount = childNodeWithName("//highScoreCount") as! SKLabelNode
        yourScoreCount = childNodeWithName("//yourScoreCount") as! SKLabelNode
        restartSquare = childNodeWithName("//restartSquare") as! MSButtonNode
        resumeSquare = childNodeWithName("//resumeSquare") as! MSButtonNode
        resumeSquare.hidden = true
        addRope()
        restartSquare.hidden = true
        physicsWorld.contactDelegate = self
        restartSquare.selectedHandler = {
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
            self.restartSquare.hidden = true
            self.state = .playing

        }
        pauseSquare.selectedHandler = {
            self.restartSquare.hidden = false
            self.state = .pause
            self.hero.physicsBody?.dynamic = false
            self.resumeSquare.hidden = false
        }
        resumeSquare.selectedHandler = {
            self.state = .playing
            self.resumeSquare.hidden = true
            self.restartSquare.hidden = true
            self.hero.physicsBody?.dynamic = true
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if state == .playing {
            if sinceTouch > 1 {
                if let ropePinJoint = ropePinJoint {
                    physicsWorld.removeJoint(ropePinJoint)
                    hangingOnRope = false
                    arrayOfRopes[previousRopeIndex].removeFromParent()
                    previousRopeIndex += 1
                    
                }
                ground.removeFromParent()
                hero.physicsBody?.velocity = CGVectorMake(0,0)
                //hero.physicsBody?.applyImpulse(CGVectorMake(0, 5))
                
                if hero.position.y > 200 {
                    hero.physicsBody?.applyImpulse(CGVectorMake(0, 0.01))
                    print("highest")
                } else if hero.position.y > 180 {
                    hero.physicsBody?.applyImpulse(CGVectorMake(0, 0.3))
                    print("middle")
                } else {
                    hero.physicsBody?.applyImpulse(CGVectorMake(0, 0.5))
                    print("lowest")
                }
                
                sinceTouch = 0
                addRope()
                moveRopes()
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if hero.position.y < 0 {
            state = .gameOver
        }
        if state == .gameOver {
            yourScoreCount.text = String(score)
            highScoreCount.text = String()
            gameOverSquare.hidden = false
            restartSquare.hidden = false
            var hs = GameManager.sharedHighScore.sharedHighScore1
            if score > hs {
                GameManager.sharedHighScore.sharedHighScore1 = score
                hs = GameManager.sharedHighScore.sharedHighScore1
            }
            highScoreCount.text = String(hs)

        }
        /* Called before each frame is rendered */
        if state == .playing {
            let velocityY = hero.physicsBody?.velocity.dy ?? 0
            
            if velocityY > 400 {
                hero.physicsBody?.velocity.dy = 400
            }
            sinceTouch += fixedDelta
            sinceDeletion += fixedDelta
            
            /*
            if let ropePinJoint = ropePinJoint {
                if sinceDeletion > 0.3 {
                    physicsWorld.removeJoint(ropePinJoint)
                    hero.physicsBody!.mass = 0.066
                    sinceDeletion = 0
                }
            }
             */
            
            for rope in arrayOfRopes {
                var rotateBy:CGFloat
                
                if rope.swingingDirection == .Right {
                    rotateBy = CGFloat(0.1)
                }
                else {
                    rotateBy = CGFloat(-0.1)
                }
                let swing = SKAction.rotateByAngle(rotateBy, duration: 0.5)
                
                if rope.swingingDirection == .Right {
                    if Double(rope.rope.zRotation) > rope.storedAngle  {
                        rope.swingingDirection = .Left
                        rope.storedAngle = -rope.storedAngle
                    }
                }
                
                else if rope.swingingDirection == .Left {
                    if Double(rope.rope.zRotation) < rope.storedAngle {
                        rope.swingingDirection = .Right
                        rope.storedAngle = -rope.storedAngle
                    }
                }
                
                //print("rope stored angle: \(rope.storedAngle)")
                //print("rope z rotation: \(rope.rope.zRotation)")
                //print("rotateBy: \(rotateBy)")
     
                rope.rope.runAction(swing)
                
            }
        }
       // let currentAngle = rope.rope.zRotation
    }
    
    func addRope (){
        
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        
        let resourcePath = NSBundle.mainBundle().pathForResource("Rope", ofType: "sks")
        let rope = Rope(URL: NSURL (fileURLWithPath: resourcePath!))
        addChild(rope)
        arrayOfRopes.append(rope)
        if arrayOfRopes.count == 1 {
            rope.position = firstRopePosition
        } else {
            rope.position = CGPoint(x: arrayOfRopes[arrayOfRopes.count - 2].position.x + CGFloat(ropeSpacing), y:firstRopePosition.y)
        }
        
        //for rope in arrayOfRopes {
            //print("*")
        //}
    
    
        
        var randomAngle = drand48()
        if randomAngle < 0.3 {
            randomAngle = 0.3
        }
        
        rope.storedAngle = randomAngle
        
        let ropePinJoint = SKPhysicsJointPin.jointWithBodyA(rope.skyPin.physicsBody!, bodyB: rope.rope.physicsBody!,
                                                            anchor: CGPoint(x:rope.position.x + 5,y: rope.position.y + 200))
        physicsWorld.addJoint(ropePinJoint)
    }
    
    func moveRopes() {
        let move = SKAction.moveBy(CGVector(dx: -ropeSpacing, dy: 0), duration: 0.6)
        for rope in arrayOfRopes {
            rope.runAction(move)
            
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
       if hangingOnRope == true  {
            return
        }
        //print("contact")
        
        /* Ensure only called while game running */
        //if gameState != .Active { return }
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "hero" {
            nodeA.physicsBody?.allowsRotation = false
            nodeA.physicsBody?.mass = 0.0001
        } else {
            nodeB.physicsBody?.allowsRotation = false
            nodeB.physicsBody?.mass = 0.0001
        }
        
        
        /* hero contacted rope */
        if (nodeA.name == "hero" || nodeB.name == "hero") && nodeA.name != "ground" && nodeB.name != "ground" && nodeA.name != "skyPin" && nodeB.name != "skyPin"  {
            let heroPositionAtContact = contact.contactPoint
            
          //  if contact.contactPoint.y > 260 {
                //heroPositionAtContact = CGPoint(x: contact.contactPoint.x, y: contact.contactPoint.y - 100)
                //let slideDown = SKAction.moveTo(CGPoint(x:0,y:0), duration: 1)
                //nodeB.runAction(slideDown)
         //   }
            
            
            ropePinJoint = SKPhysicsJointPin.jointWithBodyA(nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: heroPositionAtContact)
            physicsWorld.addJoint(ropePinJoint!)
            
            score += 1
            scoreLabel.text = String(score)
            /*
            
            if nodeA.name == "rope"  {
              //  if contact.contactPoint.y < 170 {
                ropePinJoint = SKPhysicsJointPin.jointWithBodyA(nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: contact.contactPoint )
                physicsWorld.addJoint(ropePinJoint!)
               // }    else {
                   // ropePinJoint = SKPhysicsJointPin.jointWithBodyA(nodeB.physicsBody!, bodyB: nodeA.physicsBody!, anchor: CGPoint(x: contact.contactPoint.x, y: 170 ))
                   // physicsWorld.addJoint(ropePinJoint!)
                    //var slideDown = SKAction.moveTo(CGPoint(x: contact.contactPoint.x, y: 170), duration: 1)
                    //nodeB.runAction(slideDown)
              //  }
            }
            else {
              // if contact.contactPoint.y < 170 {
                    ropePinJoint = SKPhysicsJointPin.jointWithBodyA(nodeB.physicsBody!, bodyB: nodeA.physicsBody!, anchor: contact.contactPoint )
                    physicsWorld.addJoint(ropePinJoint!)
             //  } else {
                
                  //ropePinJoint = SKPhysicsJointPin.jointWithBodyA(nodeB.physicsBody!, bodyB: nodeA.physicsBody!, anchor: CGPoint(x: contact.contactPoint.x, y: 170 ))
                  //physicsWorld.addJoint(ropePinJoint!)
                  //var slideDown = SKAction.moveTo(CGPoint(x: contact.contactPoint.x, y: 170), duration: 1)
                  //nodeA.runAction(slideDown)
              // }
            }
 
            */
            hangingOnRope = true
        }
        
    }
    
}
