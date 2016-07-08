//
//  Rope.swift
//  DopeRopes
//
//  Created by Ross Justin on 7/5/16.
//  Copyright © 2016 Ross, Yulia. All rights reserved.
//

import Foundation
import SpriteKit

enum RotationDirection {
    case Left, Right
}

class Rope: SKReferenceNode {
    
    /* Avatar node connection */
    var rope: SKSpriteNode!
    var skyPin: SKSpriteNode!
    
    var storedAngle = 0.0
    var swingingDirection:RotationDirection = .Right
    
    override func didLoadReferenceNode(node: SKNode?) {
        
        skyPin = childNodeWithName("//skyPin") as! SKSpriteNode
        rope = childNodeWithName("//rope") as! SKSpriteNode
        
        
    }
}