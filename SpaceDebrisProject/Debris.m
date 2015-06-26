//
//  Debris.m
//  SpaceDebrisProject
//
//  Created by LeeSangchan on 2015. 6. 16..
//  Copyright (c) 2015년 LeeSangchan. All rights reserved.
//

#import "Debris.h"
#import "MyConst.h"

@implementation Debris

-(instancetype)initWithPosition:(CGPoint)position {
    self = [self init];
    if (!self) return nil;
    
    self.position = position;
    
    CGSize debrisSize = CGSizeMake(7.0 + (arc4random() % 10), 7.0 + (arc4random()%10));
    
    SKSpriteNode *debris = [[SKSpriteNode alloc]initWithColor:[UIColor brownColor] size:debrisSize];
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:debrisSize];
    self.physicsBody.dynamic = YES;
    self.physicsBody.density = 1;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask = DEBRIS;
    self.physicsBody.collisionBitMask = PLANET | SATELLITE | DEBRIS;
    self.physicsBody.contactTestBitMask = PLANET | SATELLITE | DEBRIS;
    
    [self addChild:debris];
 
    return self;
}

-(void)update {
    
}

@end
